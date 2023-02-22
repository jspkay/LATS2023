#include <argp.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/queue.h>
#include <sys/wait.h>
#include <unistd.h>
#include <ncurses.h>
#include <poll.h>
#include <stdarg.h>

#define STIMULI_PER_CLASS 10
#define STIMULI_CLASSES 10
#define STIMULI_TOT STIMULI_CLASSES *STIMULI_PER_CLASS

#define SIMULATION_PROCESSES 10
#define PROPAGATION_PROCESSES 10

#define SIMULATION_PROGRAM "./sfc.startSimulation"
#define PROPAGATION_PROGRAM "./sfc.propagate"

#define PIPE_READ 0
#define PIPE_WRITE 1

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
WINDOW *mainInfo, *otherInfo;

int done = 0; // shared variables
int propagateDone = 0;

void displayInfo(int line){
	pthread_mutex_lock(&infoMutex);
  static int offset = 0;
  int startLine = line;
  int stopLine = line+1;
  if(line < 0){
    werase(mainInfo);
    if(line == -0x100) offset++;
    if(line == -0x200) offset--;
    startLine = 0;
    stopLine = SIMULATION_PROCESSES+PROPAGATION_PROCESSES+1;
  }
  for(int line=startLine; line<stopLine; line++)
    mvwprintw(mainInfo, offset+line + 1, 0, " [%2d] %s - %s %s", line, threadType[line], infoBuffer[line], "          ");
  box(mainInfo, 0, 0);
  wrefresh(mainInfo);
	pthread_mutex_unlock(&infoMutex);
}

void refreshOtherInfo(){ wrefresh(otherInfo);  }

void displayOtherInfo(const char *restrict format, ...){
	va_list args;
	va_start(args, format);
	pthread_mutex_lock(&infoMutex);
	vw_printw(otherInfo, format, args);
	refreshOtherInfo();
	pthread_mutex_unlock(&infoMutex);
	va_end(args);
}

void simulate(int *p_id) {
  int id = *p_id;
  free(p_id);
  struct simulationEntry *se;
  struct propagationEntry *pe;

  sprintf(infoBuffer[id], "thread entered - waiting...");
  displayInfo(id);

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
    char argv[3][15];
    sprintf(argv[0], "%ld", se->faultID);
    sprintf(argv[1], "%ld", se->stimulusID);
    sprintf(argv[2], "%d", id); // this identifies the library to use
    sprintf(infoBuffer[id], "simulating %ld %ld", se->faultID, se->stimulusID);
    displayInfo(id);

    int comm[2];
    pipe(comm);
    pid_t pid = fork();
    if (pid == 0) {
      // printf("%d child running exec\n", id);
      close(comm[PIPE_READ]);
      dup2(comm[PIPE_WRITE], 1);
      dup2(comm[PIPE_WRITE], 2);
      int ret = execl(SIMULATION_PROGRAM, "/bin/bash", argv[0], argv[1],
                      argv[2], NULL);
      if (ret) {
        printf("Something wrong with exec.\n");
        printf("Errno: %d\n", errno);
        exit(39);
      }
    }
    close(comm[PIPE_WRITE]);
    int exitStatus, ret=0;
    char pipeBuffer[1000];
    int pipeBufferLength = 0;
    struct pollfd ppp = {comm[PIPE_READ], POLLIN};
    while(ret != pid){
      poll(&ppp, 1, 500);
      if( (ppp.revents&POLLIN) != 0){
        char c;
        read(comm[PIPE_READ], &c, 1);
        if(c != '\n') pipeBuffer[pipeBufferLength++] = c;
        else {
          pipeBuffer[pipeBufferLength++] = '\n';
          pipeBuffer[pipeBufferLength++] = 0;
          pipeBufferLength = 0;
          displayOtherInfo("%s", pipeBuffer);
        }
      }
      ret = waitpid(pid, &exitStatus, WNOHANG);
    }

    close(comm[PIPE_READ]);

    // if anything goes wrong, let's process the element again
    if (!WIFEXITED(exitStatus) ||
        (WIFEXITED(exitStatus) && WEXITSTATUS(exitStatus))) {
      if (WEXITSTATUS(exitStatus) ==
          1) { // Simulation was previously done, skipping.
        // actually nothing to do...
        sprintf(infoBuffer[id], "already simulated OK");
        displayInfo(id);
      } else {
        // if the process was terminated abnormally
        // or if the process terminated with a status different from 0 or 1
        // we redo the simulation as soon as possible
        pthread_mutex_lock(&simulationMutex);
        STAILQ_INSERT_HEAD(&simulationQueue, se, next);
        simulationQueueLength++;
        pthread_mutex_unlock(&simulationMutex);
        //printf("%d - rerun simulation!!!\n", id);
      }
    } else { // The simulation was ok, process exited with 0
      sprintf(infoBuffer[id], "simulation OK");
      displayInfo(id);
      // if the simulation has gone ok, we run propagation
      pe = (struct propagationEntry *) se; // since the structure of the entry is exactly the same, we can
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
  
  // refresh screen
  sprintf(infoBuffer[id], "exiting...");
  displayInfo(id);

  pthread_exit(NULL); // terminate the thread
}

void propagate(int *p_id) {
  int id = *p_id;
  free(p_id);
  struct propagationEntry *pe;
  sprintf(infoBuffer[id], "thread entered - waiting...");
  displayInfo(id);

  pthread_mutex_lock(&propagationMutex);
  pthread_cond_wait(&propagationCV, &propagationMutex);

  while (!STAILQ_EMPTY(&propagationQueue)) {
    // remove an element from the queue
    pe = STAILQ_FIRST(&propagationQueue);
    STAILQ_REMOVE_HEAD(&propagationQueue, next);
    pthread_mutex_unlock(&propagationMutex); // release the mutex

    // execute the simulation step (with a new process)
    char argv[3][15];
    sprintf(argv[0], "%ld", pe->faultID);
    sprintf(argv[1], "%ld", pe->stimulusID);
    sprintf(argv[2], "%d", id);
    sprintf(infoBuffer[id], "Propagating %ld %ld", pe->faultID, pe->stimulusID);
    displayInfo(id);

    int comm[2];
    pipe(comm);
    pid_t pid = fork();
    if (pid == 0) {
      close(comm[PIPE_READ]);
      dup2(comm[PIPE_WRITE], 1);
      dup2(comm[PIPE_WRITE], 2);
      execl(PROPAGATION_PROGRAM, "/bin/bash", argv[0], argv[1], argv[2], NULL);
      printf("SOMETHING WENT TERRIBLY WRONG.\n");
      printf("ERRNO: %d\n", errno);
      exit(40);
    }
    close(comm[PIPE_WRITE]);
    int exitStatus, ret=0;
    char pipeBuffer[1000];
    int pipeBufferLength = 0;
    struct pollfd ppp = {comm[PIPE_READ], POLLIN};
    while(ret != pid){
      poll(&ppp, 1, 500);
      if( (ppp.revents&POLLIN) != 0){
        char c;
        read(comm[PIPE_READ], &c, 1);
        if(c != '\n') pipeBuffer[pipeBufferLength++] = c;
        else{
          pipeBuffer[pipeBufferLength++] ='\n';
          pipeBuffer[pipeBufferLength++] = 0;
          pipeBufferLength = 0;
          displayOtherInfo("%s", pipeBuffer);
        }
      }
      ret = waitpid(pid, &exitStatus, WNOHANG);
    }

    close(comm[PIPE_READ]);

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
      displayOtherInfo("%d - rerun propagation %d %d!!!\n", id, pe->faultID, pe->stimulusID);
      continue; // nothing else to do
    }
    sprintf(infoBuffer[id], "Propagation OK %ld %ld", pe->faultID, pe->stimulusID);
    displayInfo(id);
    free(pe); // we free the memory
    pthread_mutex_lock(&propagationMutex);
    pthread_cond_wait(&propagationCV, &propagationMutex);
  }

  propagateDone++;
  pthread_mutex_unlock(&propagationMutex);

  sprintf(infoBuffer[id], "exiting...                ");
  displayInfo(id);

  pthread_exit(NULL); // terminate the thread
}

struct arguments {
  long startIndex, endIndex;
  char *sessionFile;
  int externalFaults;
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
  case 'e':
    arguments->externalFaults = 1;
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
      //{"resume", 'r', "filename", 0, "Resume filename"},
      {"external-faults", 'e', 0, 0, "If present, the faults are not generated but read from the 'faults/' directory"},
      {0} };
  struct argp argp = {options, parse_opt, 0, 0};
  argp_parse(&argp, argc, argv, 0, 0, &arguments);

  //printf("Arguments: %ld to %ld - session file %s", arguments.startIndex,
  //       arguments.endIndex, arguments.sessionFile);
  // Preparation

  if(arguments.endIndex < arguments.startIndex){
    printf("Cannot run the program with an end index (%ld) lower than the start index (%ld)",
           arguments.endIndex, arguments.startIndex);
    exit(1);
  }

  if (arguments.sessionFile == 0) {
    arguments.sessionFile =
        (char *)malloc(100 * sizeof(char)); // 100 characters
    sprintf(arguments.sessionFile, "sfc.session");
  }

  /* ncurses */
  initscr();
  cbreak();
  noecho();
  keypad(stdscr, TRUE);
  curs_set(0);
    struct {int startx, starty, x, y;} otherWin, mainWin;
    if(SIMULATION_PROCESSES+PROPAGATION_PROCESSES+3 > LINES/2){
      mainWin.startx = 0;
      mainWin.starty = 0;
      mainWin.x = LINES;
      mainWin.y = COLS/2;

      otherWin.startx = 0;
      otherWin.starty = COLS/2;
      otherWin.x = LINES;
      otherWin.y = COLS/2 - 3;
    }else{
      mainWin.x = SIMULATION_PROCESSES+PROPAGATION_PROCESSES+3;
      mainWin.y = COLS;
      mainWin.startx = 0;
      mainWin.starty = 0;

      otherWin.x = LINES - SIMULATION_PROCESSES - PROPAGATION_PROCESSES - 5;
      otherWin.y = COLS;
      otherWin.startx =  SIMULATION_PROCESSES + PROPAGATION_PROCESSES + 3;
      otherWin.starty = 0;
    }

    mainInfo = newwin(mainWin.x, mainWin.y, mainWin.startx, mainWin.starty);
    otherInfo = newwin(otherWin.x, otherWin.y, otherWin.startx, otherWin.starty);
  wrefresh(mainInfo);
  wrefresh(otherInfo);
  scrollok(otherInfo, TRUE);

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
  sprintf(threadType[id], "main thread");
  float percentage = 0;
  float faultPercentage = 0;
  float singleFaultPerc = 100 * (float)1 / ((float)arguments.endIndex - (float)arguments.startIndex + 1);
  float stim_tot =  STIMULI_TOT;

  struct simulationEntry *simulationElement;
  long nextFaultID = arguments.startIndex-1, stimuliCount = STIMULI_TOT;
  long stimulusList[100];

  sprintf(infoBuffer[id], "Processed %.3f%% - fault(%ld/%ld) stimulus(%ld of %d) ", percentage, nextFaultID, arguments.endIndex, stimuliCount, STIMULI_TOT);
  displayInfo(id);

  displayOtherInfo("Everything ready. Press <CTRL+c> or 'q' to exit.\n"
                   "Press any other key to continue...\n");
  struct pollfd ppp = {STDIN_FILENO, POLLIN};
  int ok=0;
  while(!ok){
    poll(&ppp, 1, 500);
    if( ppp.revents != 0) {
      char c = getch();
      if(c == 'q') done=1;
      ok = 1;
    }
    wrefresh(mainInfo);
    refreshOtherInfo();
  }

  while (!done) {
    pthread_mutex_lock(&simulationMutex); // producing new elements
    while (simulationQueueLength < SIMULATION_PROCESSES) {
      if (stimuliCount < STIMULI_TOT) {
        simulationElement = malloc(sizeof(struct simulationEntry));
        simulationElement->faultID = nextFaultID;
        simulationElement->stimulusID = stimulusList[stimuliCount++];
        STAILQ_INSERT_TAIL(&simulationQueue, simulationElement, next);
        simulationQueueLength++;
	
        displayOtherInfo("Added %ld - %ld. Tot %d\n", simulationElement->faultID,
                simulationElement->stimulusID, simulationQueueLength);

        percentage = faultPercentage + singleFaultPerc * (float) stimuliCount/ stim_tot;
        sprintf(infoBuffer[id], "Processed %.3f%% - fault(%ld/%ld) stimulus(%ld of %d) ", percentage, nextFaultID, arguments.endIndex, stimuliCount, STIMULI_TOT);
        displayInfo(id);
      } else if (nextFaultID < arguments.endIndex) { // next fault
        nextFaultID++;

        char program[500];
        if(!arguments.externalFaults) { // if external faults is not set, we use fangy
          // generate fault
          char faultFilename[] = "faults/fault_XXXXX";
          sprintf(faultFilename, "faults/fault_%ld", nextFaultID);
          sprintf(program, "fangy fault_list.template --seed %ld --output %s",
                  nextFaultID, faultFilename);
          system((const char *) program);
        } // Otherwise, we just miss this step.

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
          //printf("%ld\n", stimulusList[i]);
          i++;
        }
        stimuliCount = 0; // start from the first
        fclose(stimuliListFile);

        faultPercentage = 100 * (float)(nextFaultID-arguments.startIndex) / ((float)arguments.endIndex - (float)arguments.startIndex + 1);
      } else
        break; // nothing to do.
    }
    pthread_mutex_unlock(&simulationMutex); // production finished
    pthread_cond_broadcast(&simulationCV);

    // Terminal resize if necessary
    struct pollfd ppp = {STDIN_FILENO, POLLIN};
    poll(&ppp, 1, 500);
    if(ppp.revents != 0){
      int c = getch(); // if there is KEY_RESIZE, it will resize.
      if(c == KEY_RESIZE) displayInfo(-1);
      else if(c == KEY_UP) displayInfo(-0x100);
      else if(c == KEY_DOWN) displayInfo(-0x200);
    }

    // check terminating condition!
    if (STAILQ_EMPTY(&simulationQueue) && nextFaultID == arguments.endIndex &&
      stimuliCount == STIMULI_TOT) {
      sprintf(infoBuffer[id], "Progress 100%%. All the simulations have been queued. Termination imminent.");
      displayInfo(id);
      done = 1;
    }
  }

  displayOtherInfo("Simulation queue complete. Termination\n");

  displayOtherInfo("Waiting for simulation thread...\n");
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

  displayOtherInfo("Simulation threads finished.\nWaiting for propagation threads...\n");
  while (propagateDone < PROPAGATION_PROCESSES) {
    pthread_cond_broadcast(&propagationCV);
  }
  pthread_cond_signal(&propagationCV);
  for (int i = 0; i < PROPAGATION_PROCESSES; i++) {
    pthread_join(propagationThreads[i], NULL);
  }

  displayOtherInfo("Everything done! Congratulations!\n");
  displayOtherInfo("Press 'q' to exit");

  ok = 0;
  wprintw(otherInfo, "\n");
  wrefresh(otherInfo);
  while(!ok) {
    poll(&ppp, 1, 500);
    if(ppp.revents != 0) {
      int c;
      c = getch();
      if (c == 'q') ok = 1;
      else if(c == KEY_RESIZE){
        displayInfo(-1);
        refreshOtherInfo();
      }
      else if(c == KEY_UP){
        displayInfo(-0x100);
      }
      else if(c == KEY_DOWN){
        displayInfo(-0x200);
      }
    }
    wrefresh(otherInfo);
    wrefresh(mainInfo);
  }

  pthread_mutex_destroy(&simulationMutex);
  pthread_mutex_destroy(&propagationMutex);
  pthread_cond_destroy(&propagationCV);
  delwin(mainInfo);
  delwin(otherInfo);
  endwin();

  return 0;
}
