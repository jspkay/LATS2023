#include <argp.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/queue.h>
#include <sys/wait.h>
#include <unistd.h>

#define STIMULI_PER_CLASS 10
#define STIMULI_CLASSES 10
#define STIMULI_TOT STIMULI_CLASSES *STIMULI_PER_CLASS

#define SIMULATION_PROCESSES 10
#define PROPAGATION_PROCESSES 5

#define SIMULATION_PROGRAM "./sfc.startSimulation"
#define PROPAGATION_PROGRAM "./sfc.propagate"

// simulation queue
struct simulationEntry {
  long faultID, stimulusID;
  STAILQ_ENTRY(simulationEntry) next;
};
STAILQ_HEAD(simulationQueueHead, simulationEntry);
struct simulationQueueHead simulationQueue;
int simulationQueueLength;       // this is needed for the termination condition
pthread_mutex_t simulationMutex; // mutex for writing the queue
pthread_cond_t simulationCV;

// propagation queue
struct propagationEntry {
  long faultID, stimulusID;
  STAILQ_ENTRY(propagationEntry) next;
};
STAILQ_HEAD(propagationQueueHead, propagationEntry);
struct propagationQueueHead propagationQueue;
// propagation CV
pthread_mutex_t propagationMutex;
pthread_cond_t propagationCV;
// A total of 15 (+ main) processes can be destined to this program

// Info display handling
pthread_mutex_t infoMutex;
char infoBuffer[SIMULATION_PROCESSES+PROPAGATION_PROCESSES+1][1000];
char threadType[SIMULATION_PROCESSES+PROPAGATION_PROCESSES+1][100];

int done = 0; // shared variables
int propagateDone = 0;

void displayInfo(){
	pthread_mutex_lock(&infoMutex);
  printf("\e[1;1H\e[2J"); // clear the console
	for(int i=0; i<SIMULATION_PROCESSES+PROPAGATION_PROCESSES+1; i++){
		printf("[%d] %s - %s\n", i, threadType[i], infoBuffer[i]);
	}
	fflush(stdout);
	pthread_mutex_unlock(&infoMutex);
}

void simulate(int *p_id) {
  int id = *p_id;
  struct simulationEntry *se;
  struct propagationEntry *pe;

  sprintf(infoBuffer[id], "[Simulation] thread entered!");

  // Getting the first element
  pthread_mutex_lock(&simulationMutex);
  while (simulationQueueLength == 0)
    pthread_cond_wait(&simulationCV, &simulationMutex);

  // The queue is empty ONLY if the main thread doesn't put elements inside
  while (!STAILQ_EMPTY(&simulationQueue)) {
    se = STAILQ_FIRST(&simulationQueue);
    STAILQ_REMOVE_HEAD(&simulationQueue, next);
    simulationQueueLength--;
    pthread_mutex_unlock(&simulationMutex);
    // execute the simulation step (with a new process)
    char argv[3][10];
    sprintf(argv[0], "%ld", se->faultID);
    sprintf(argv[1], "%ld", se->stimulusID);
    sprintf(argv[2], "%d", id); // this identifies the library to use
    sprintf(infoBuffer[id], "simulating %ld %ld", se->faultID, se->stimulusID);
    displayInfo();
    pid_t pid = fork();
    if (pid == 0) {
      // printf("%d child running exec\n", id);
      int ret = execl(SIMULATION_PROGRAM, "/bin/bash", argv[0], argv[1],
                      argv[2], NULL);
      if (ret) {
        printf("Something wrong with exec.\n");
        printf("Errno: %d\n", errno);
        exit(39);
      }
    }
    int exitStatus;
    waitpid(pid, &exitStatus, 0);

    // if anything goes wrong, let's process the element again
    if (!WIFEXITED(exitStatus) ||
        (WIFEXITED(exitStatus) && WEXITSTATUS(exitStatus))) {
      if (WEXITSTATUS(exitStatus) ==
          1) { // Simulation was previously done, skipping.
        // actually nothing to do...
      } else {
        // if the process was terminated abnormally
        // or if the process terminated with a status different from 0 or 1
        // we redo the simulation as soon as possible
        pthread_mutex_lock(&simulationMutex);
        STAILQ_INSERT_HEAD(&simulationQueue, se, next);
        simulationQueueLength++;
        pthread_mutex_unlock(&simulationMutex);
        printf("%d - rerun simulation!!!\n", id);
      }
    } else { // The simulation was ok, process exited with 0
      sprintf(infoBuffer[id], "simulation OK");
      displayInfo();
      // if the simulation has gone ok, we run propagation
      pe = (struct propagationEntry *)
          se; // since the structure of the entry is exactly the same, we can
              // just reuse the address.
      pthread_mutex_lock(&propagationMutex);
      STAILQ_INSERT_TAIL(&propagationQueue, pe, next);
      pthread_mutex_unlock(&propagationMutex);
      pthread_cond_signal(&propagationCV);
    }

    pthread_mutex_lock(&simulationMutex);
    while (simulationQueueLength == 0)
      pthread_cond_wait(&simulationCV, &simulationMutex); // wait for condition
  }

  // the lock is locked from the wait
  done++;
  pthread_mutex_unlock(&simulationMutex);

  free(p_id);
  pthread_exit(NULL); // terminate the thread
}

void propagate(const int *p_id) {
  int id = *p_id;
  struct propagationEntry *pe;
  sprintf(infoBuffer[id], "thread entered - waiting...");
  displayInfo();

  pthread_mutex_lock(&propagationMutex);
  pthread_cond_wait(&propagationCV, &propagationMutex);

  while (!STAILQ_EMPTY(&propagationQueue)) {
    // remove an element from the queue
    pe = STAILQ_FIRST(&propagationQueue);
    STAILQ_REMOVE_HEAD(&propagationQueue, next);
    pthread_mutex_unlock(&propagationMutex); // release the mutex

    // execute the simulation step (with a new process)
    char argv[3][5];
    sprintf(argv[0], "%ld", pe->faultID);
    sprintf(argv[1], "%ld", pe->stimulusID);
    sprintf(argv[2], "%d", id);
    sprintf(infoBuffer[id], "Propagating %ld %ld", pe->faultID, pe->stimulusID);
    displayInfo();
    pid_t pid = fork();
    if (pid == 0) {
      execl(PROPAGATION_PROGRAM, "./bin/bash", argv[0], argv[1], argv[2], NULL);
    }
    int exitStatus;
    waitpid(pid, &exitStatus, 0);

    // if anything goes wrong, let's process the element again
    if (!WIFEXITED(exitStatus) ||
        (WIFEXITED(exitStatus) && WEXITSTATUS(exitStatus))) {
      // if the process was terminated abnormally
      // or if the process terminated with a status different from 0
      if (WEXITSTATUS(exitStatus) == 10) {
        printf("EEERRRORREEEEEE!!!!!\n");
        exit(0);
      }
      pthread_mutex_lock(&propagationMutex);
      STAILQ_INSERT_HEAD(&propagationQueue, pe,
                         next); // process as the next element!!!
      pthread_mutex_unlock(&propagationMutex);
      pthread_cond_signal(&propagationCV); // unlock a thread
      printf("%d - rerun propagation!!!\n", id);
      continue; // nothing else to do
    }
    sprintf(infoBuffer[id], "Propagation OK %ld %ld", pe->faultID, pe->stimulusID);
    displayInfo();
    free(pe); // we free the memory
    pthread_mutex_lock(&propagationMutex);
    pthread_cond_wait(&propagationCV, &propagationMutex);
  }

  propagateDone++;
  pthread_mutex_unlock(&propagationMutex);

  pthread_exit(NULL); // terminate the thread
}

struct arguments {
  long startIndex, endIndex;
  char *sessionFile;
};
error_t parse_opt(int key, char *arg, struct argp_state *state) {
  struct arguments *arguments = state->input;

  switch (key) {
  case 'i':
    arguments->startIndex = strtol(arg, NULL, 10);
    break;
  case 'f':
    arguments->endIndex = strtol(arg, NULL, 10);
    break;
  case 'r':
    arguments->sessionFile = arg;
    break;
  default:
    return ARGP_ERR_UNKNOWN;
  }
  return 0;
}

int main(int argc, char **argv) {
  struct arguments arguments = {0};
  struct argp_option options[] = {
      {"start", 'i', "startIndex", 0,
       "The start index for generating the faults"},
      {"stop", 'f', "stopIndex", 0, "Stop index for the faults"},
      {"resume", 'r', "filename", 0, "Resume filename"},
      {0}};
  struct argp argp = {options, parse_opt, 0, 0};
  argp_parse(&argp, argc, argv, 0, 0, &arguments);

  printf("Arguments: %ld to %ld - session file %s", arguments.startIndex,
         arguments.endIndex, arguments.sessionFile);
  // Preparation

  if(arguments.endIndex < arguments.startIndex){
    printf("Cannot run the program with an end index (%ld) lower than the start index (%ld)",
           arguments.endIndex, arguments.startIndex);
  }

  if (arguments.sessionFile == 0) {
    arguments.sessionFile =
        (char *)malloc(100 * sizeof(char)); // 100 characters
    sprintf(arguments.sessionFile, "sfc.session");
  }

  /* SEARCH WHETHER THE FILE EXISTS AND LOAD IT */

  /* OBJECTS INITIALIZATION */
  STAILQ_INIT(&simulationQueue);
  simulationQueueLength = 0;
  pthread_mutex_init(&simulationMutex, NULL);
  pthread_cond_init(&simulationCV, NULL);

  STAILQ_INIT(&propagationQueue);
  pthread_mutex_init(&propagationMutex, NULL);
  pthread_cond_init(&propagationCV, NULL);

  pthread_mutex_init(&infoMutex, NULL);

  for (int i=0; i<SIMULATION_PROCESSES+1; i++){
	  printf("#\n"); // one line per thread, the last is main
  }

  // thread creation
  pthread_t simulationThreads[SIMULATION_PROCESSES];
  for (int i = 0; i < SIMULATION_PROCESSES; i++) {
    sprintf(threadType[i], "SIMULATION");
    int *p = malloc(sizeof(int));
    *p = i;
    pthread_create(&(simulationThreads[i]), NULL, (void *)simulate, p);
  }
  pthread_t propagationThreads[PROPAGATION_PROCESSES];
  for (int i = 0; i < PROPAGATION_PROCESSES; i++) {
    int *p = malloc(sizeof(int));
    *p = SIMULATION_PROCESSES + i;
    sprintf(threadType[*p], "PROPAGATION");
    pthread_create(propagationThreads + i, NULL, (void *)propagate, p);
  }

  int id = PROPAGATION_PROCESSES+SIMULATION_PROCESSES;
  sprintf(threadType[id], "main");
  float percentage;
  float faultPercentage;
  float singleFaultPerc = 100 * (float)1 / ((float)arguments.endIndex - (float)arguments.startIndex + 1);
  float stim_tot =  STIMULI_TOT;

  struct simulationEntry *simulationElement;
  long nextFaultID = arguments.startIndex-1, stimuliCount = STIMULI_TOT;
  long stimulusList[100];
  while (!done) {
    pthread_mutex_lock(&simulationMutex); // producing new elements
    while (simulationQueueLength < SIMULATION_PROCESSES) {
      if (stimuliCount < STIMULI_TOT) {
        simulationElement = malloc(sizeof(struct simulationEntry));
        simulationElement->faultID = nextFaultID;
        simulationElement->stimulusID = stimulusList[stimuliCount++];
        STAILQ_INSERT_TAIL(&simulationQueue, simulationElement, next);
        simulationQueueLength++;
        printf("Added %ld - %ld. Tot %d\n", simulationElement->faultID,
               simulationElement->stimulusID, simulationQueueLength);

        percentage = faultPercentage + singleFaultPerc * (float) stimuliCount/ stim_tot;
        sprintf(infoBuffer[id], "Processed %.3f%% - fault(%ld/%ld) stimulus(%ld of %d) ", percentage, nextFaultID, arguments.endIndex, stimuliCount, STIMULI_TOT);
      } else if (nextFaultID < arguments.endIndex) { // next fault
        // generate fault
        char program[500];
        char faultFilename[] = "faults/fault_XXXXX";
        sprintf(faultFilename, "faults/fault_%ld", nextFaultID);
        sprintf(program, "fangy fault_list.template --seed %ld --output %s",
                nextFaultID, faultFilename);
        system((const char *)program);

        // generate Stimuli list
        sprintf(program,
                "generateRandomStimuliList.py -i data/stimuli.db -k %d -o "
                "stimuli.list.sfc -s %ld data/stimuli --id-only",
                STIMULI_PER_CLASS, nextFaultID);
        system((const char *)program);

        // Stimuli IDs generated, now loading in memory
        FILE *stimuliListFile = fopen("stimuli.list.sfc", "r");
        char numberBuffer[5];
        int i = 0;
        while (!feof(stimuliListFile)) {
          fgets(numberBuffer, 5, stimuliListFile);
          fgetc(stimuliListFile);
          stimulusList[i] = strtol(numberBuffer, NULL, 10);
          i++;
        }
        stimuliCount = 0; // start from the first
        fclose(stimuliListFile);

        nextFaultID++;

        faultPercentage = 100 * (float)(nextFaultID-arguments.startIndex) / ((float)arguments.endIndex - (float)arguments.startIndex + 1);
      } else
        break; // nothing to do.
    }
    pthread_mutex_unlock(&simulationMutex); // production finished
    pthread_cond_broadcast(&simulationCV);

    // check terminating condition!
    if (STAILQ_EMPTY(&simulationQueue) && nextFaultID == arguments.endIndex &&
        stimuliCount == STIMULI_TOT) {
      printf("Terminating!\n");
      done = 1;
    }
  }

  printf("Closing the threads\n");
  pthread_mutex_lock(&simulationMutex);
  simulationQueueLength++; // wrong count for unlocking the treads
  pthread_mutex_unlock(&simulationMutex);
  // for processes to terminate
  while (done < SIMULATION_PROCESSES + 1) {
    pthread_cond_broadcast(&simulationCV);
  }
  for (int i = 0; i < SIMULATION_PROCESSES; i++) {
    pthread_join(simulationThreads[i], NULL);
  }

  printf("Simulation threads finished.\nWaiting for propagation threads.\n");
  while (propagateDone < PROPAGATION_PROCESSES)
    pthread_cond_broadcast(&propagationCV);
  pthread_cond_signal(&propagationCV);
  for (int i = 0; i < PROPAGATION_PROCESSES; i++) {
    pthread_join(propagationThreads[i], NULL);
  }

  printf("Propagation threads finished.\nDestroying the mutexes\n");
  pthread_mutex_destroy(&simulationMutex);
  pthread_mutex_destroy(&propagationMutex);
  pthread_cond_destroy(&propagationCV);

  printf("DONE\n\n\n");
  return 0;
}
