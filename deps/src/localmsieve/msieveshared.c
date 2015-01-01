/*--------------------------------------------------------------------
  This file is modified from demo.c. It is the only code in this tree
  not authored by Jason Papadopoulos.

This source distribution is placed in the public domain by its author,
John Lapeyre. You may use it for any purpose, free of charge,
without having to notify anyone. I disclaim any responsibility for any
errors.
--------------------------------------------------------------------*/

#include <msieve.h>
#include <signal.h>

#ifdef HAVE_MPI
#include <mpi.h>
#endif

msieve_obj *g_curr_factorization = NULL;

/*--------------------------------------------------------------------*/
void handle_signal(int sig) {

	msieve_obj *obj = g_curr_factorization;

	printf("\nreceived signal %d; shutting down\n", sig);
	
	if (obj && (obj->flags & MSIEVE_FLAG_SIEVING_IN_PROGRESS))
		obj->flags |= MSIEVE_FLAG_STOP_SIEVING;
	else
		_exit(0);
}

/*--------------------------------------------------------------------*/
void get_random_seeds(uint32 *seed1, uint32 *seed2) {

	uint32 tmp_seed1, tmp_seed2;

	/* In a multithreaded program, every msieve object
	   should have two unique, non-correlated seeds
	   chosen for it */

#if !defined(WIN32) && !defined(_WIN64)

	FILE *rand_device = fopen("/dev/urandom", "r");

	if (rand_device != NULL) {

		/* Yay! Cryptographic-quality nondeterministic randomness! */

		fread(&tmp_seed1, sizeof(uint32), (size_t)1, rand_device);
		fread(&tmp_seed2, sizeof(uint32), (size_t)1, rand_device);
		fclose(rand_device);
	}
	else

#endif
	{
		/* <Shrug> For everyone else, sample the current time,
		   the high-res timer (hopefully not correlated to the
		   current time), and the process ID. Multithreaded
		   applications should fold in the thread ID too */

		uint64 high_res_time = read_clock();
		tmp_seed1 = ((uint32)(high_res_time >> 32) ^
			     (uint32)time(NULL)) * 
			    (uint32)getpid();
		tmp_seed2 = (uint32)high_res_time;
	}

	/* The final seeds are the result of a multiplicative
	   hash of the initial seeds */

	(*seed1) = tmp_seed1 * ((uint32)40499 * 65543);
	(*seed2) = tmp_seed2 * ((uint32)40499 * 65543);
}

/*--------------------------------------------------------------------*/
void print_usage(char *progname) {

	printf("\nMsieve v. %d.%02d (SVN %s)\n", MSIEVE_MAJOR_VERSION, 
					MSIEVE_MINOR_VERSION,
					MSIEVE_SVN_VERSION);

	printf("\nusage: %s [options] [one_number]\n", progname);
	printf("\nnumbers starting with '0' are treated as octal,\n"
		"numbers starting with '0x' are treated as hexadecimal\n");
	printf("\noptions:\n"
	         "   -s <name> save intermediate results to <name>\n"
		 "             instead of the default %s\n"
	         "   -l <name> append log information to <name>\n"
		 "             instead of the default %s\n"
	         "   -i <name> read one or more integers to factor from\n"
		 "             <name> (default worktodo.ini) instead of\n"
		 "             from the command line\n"
		 "   -m        manual mode: enter numbers via standard input\n"
	         "   -q        quiet: do not generate any log information,\n"
		 "             only print any factors found\n"
	         "   -d <min>  deadline: if still sieving after <min>\n"
		 "             minutes, shut down gracefully (default off)\n"
		 "   -r <num>  stop sieving after finding <num> relations\n"
		 "   -p        run at idle priority\n"
	         "   -v        verbose: write log information to screen\n"
		 "             as well as to logfile\n"
#ifdef HAVE_CUDA
		 "   -g <num>  use GPU <num>, 0 <= num < (# graphics cards)>\n"
#endif
	         "   -t <num>  use at most <num> threads\n"
		 "\n"
		 " elliptic curve options:\n"
		 "   -e        perform 'deep' ECM, seek factors > 15 digits\n\n"
		 " quadratic sieve options:\n"
		 "   -c        client: only perform sieving\n\n"
		 " number field sieve options:\n\n"
		 "           [nfs_phase] \"arguments\"\n\n"
		 " where the first part is one or more of:\n"
		 "   -n        use the number field sieve (80+ digits only;\n"
		 "             performs all NFS tasks in order)\n"
	         "   -nf <name> read from / write to NFS factor base file\n"
		 "             <name> instead of the default %s\n"
		 "   -np       perform only NFS polynomial selection\n"
		 "   -np1      perform stage 1 of NFS polynomial selection\n"
		 "   -nps      perform NFS polynomial size optimization\n"
		 "   -npr      perform NFS polynomial root optimization\n"
		 "   -ns       perform only NFS sieving\n"
		 "   -nc       perform only NFS combining (all phases)\n"
		 "   -nc1      perform only NFS filtering\n"
		 "   -nc2      perform only NFS linear algebra\n"
		 "   -ncr      perform only NFS linear algebra, restarting\n"
		 "             from a previous checkpoint\n"
		 "   -nc3      perform only NFS square root\n\n"
		 " the arguments are a space-delimited list of:\n"
		 " polynomial selection options:\n"
#ifdef HAVE_CUDA
		 "   sortlib=X       use GPU sorting library X\n"
		 "   gpu_mem_mb=X    use X megabytes of GPU memory\n"
#endif
		 "   polydegree=X    select polynomials with degree X\n"
		 "   min_coeff=X     minimum leading coefficient to search\n"
		 "                   in stage 1\n"
		 "   max_coeff=X     maximum leading coefficient to search\n"
		 "                   in stage 1\n"
		 "   stage1_norm=X   the maximum norm value for stage 1\n"
		 "   stage2_norm=X   the maximum norm value for stage 2\n"
		 "   min_evalue=X    the minimum score of saved polyomials\n"
		 "   poly_deadline=X stop searching after X seconds (0 means\n"
		 "                   search forever)\n"
		 "   X,Y             same as 'min_coeff=X max_coeff=Y'\n"
		 " line sieving options:\n"
		 "   X,Y             handle sieve lines X to Y inclusive\n"
		 " filtering options:\n"
		 "   filter_mem_mb=X  try to limit filtering memory use to\n"
		 "                    X megabytes\n"
		 "   filter_maxrels=X limit the filtering to using the first\n"
		 "                    X relations in the data file\n"
		 "   filter_lpbound=X have filtering start by only looking\n"
		 "                    at ideals of size X or larger\n"
		 "   target_density=X attempt to produce a matrix with X\n"
		 "                    entries per column\n"
		 "   X,Y              same as 'filter_lpbound=X filter_maxrels=Y'\n"
		 " linear algebra options:\n"
		 "   skip_matbuild=1  start the linear algebra but skip building\n"
		 "                    the matrix (assumes it is built already)\n"
		 "   la_block=X       use a block size of X (512<=X<=65536)\n"
		 "   la_superblock=X  use a superblock size of X\n"
		 "   cado_filter=1    assume filtering used the CADO-NFS suite\n"
#ifdef HAVE_MPI
		 "   mpi_nrows=X      use a grid with X rows\n"
		 "   mpi_ncols=X      use a grid with X columns\n"
		 "   X,Y              same as 'mpi_nrows=X mpi_ncols=Y'\n"
		 "                    (if unspecified, default grid is\n"
		 "                    1 x [argument to mpirun])\n"
#endif
		 " square root options:\n"
		 "   dep_first=X start with dependency X, 1<=X<=64\n"
		 "   dep_last=Y  end with dependency Y, 1<=Y<=64\n"
		 "   X,Y         same as 'dep_first=X dep_last=Y'\n"
		 ,
		 MSIEVE_DEFAULT_SAVEFILE, 
		 MSIEVE_DEFAULT_LOGFILE,
		 MSIEVE_DEFAULT_NFS_FBFILE);
}

/*--------------------------------------------------------------------*/
int factor_integer(char *buf, uint32 flags,
                    char *savefile_name,
		    char *logfile_name,
		    char *nfs_fbfile_name,
		    uint32 *seed1, uint32 *seed2,
		    uint32 max_relations,
		    enum cpu_type cpu,
		    uint32 cache_size1,
		    uint32 cache_size2,
		    uint32 num_threads,
		    uint32 which_gpu,
                    const char *nfs_args,
                    msieve_obj **saveobj){
	
	char *int_start, *last;
        //	msieve_obj *obj;
	msieve_factor *factor;

	/* point to the start of the integer or expression;
	   if the start point indicates no integer is present,
	   don't try to factor it :) */

	last = strchr(buf, '\n');
	if (last)
		*last = 0;
	int_start = buf;
	while (*int_start && !isdigit(*int_start) &&
			*int_start != '(' ) {
		int_start++;
	}
	if (*int_start == 0)
          return(0);

	g_curr_factorization = msieve_obj_new(int_start, flags,savefile_name,
                                              logfile_name,
                                              nfs_fbfile_name,
                                              *seed1, *seed2, max_relations,
                                              cpu, cache_size1, cache_size2,
                                              num_threads, which_gpu,
					nfs_args);
	if (g_curr_factorization == NULL) {
		printf("factoring initialization failed\n");
		return(0);
	}
	msieve_run(g_curr_factorization);
	if (!(g_curr_factorization->flags & MSIEVE_FLAG_FACTORIZATION_DONE)) {
		printf("\ncurrent factorization was interrupted\n");
                return(0);
	}

	/* If no logging is specified, at least print out the
	   factors that were found */

	if (!(g_curr_factorization->flags & (MSIEVE_FLAG_USE_LOGFILE |
					MSIEVE_FLAG_LOG_TO_STDOUT))) {
		factor = g_curr_factorization->factors;
                int count = 0;
                while (factor != NULL) {
                  count++;
                  factor = factor->next;                  
                }
		factor = g_curr_factorization->factors;                
                //		printf("\n");
                //		printf("nfactors:%d:  %s\n", count, buf);
		while (factor != NULL) {
			char *factor_type;

			if (factor->factor_type == MSIEVE_PRIME)
				factor_type = "p";
			else if (factor->factor_type == MSIEVE_COMPOSITE)
				factor_type = "c";
			else
				factor_type = "prp";

                        //	printf("%s%d: %s\n", factor_type, 
                        //					(int32)strlen(factor->number), 
			//		factor->number);
			factor = factor->next;
		}
                //		printf("\n");

                //factor = g_curr_factorization->factors;
                
	}

	/* save the current value of the random seeds, so that
	   the next factorization will pick up the pseudorandom
	   sequence where this factorization left off */

	*seed1 = g_curr_factorization->seed1;
	*seed2 = g_curr_factorization->seed2;

	/* free the current factorization struct. The following
	   avoids a race condition in the signal handler */

        *saveobj = g_curr_factorization;
        return(1);
}

#ifdef WIN32
DWORD WINAPI countdown_thread(LPVOID pminutes) {
	DWORD minutes = *(DWORD *)pminutes;

	if (minutes > 0x7fffffff / 60000)
		minutes = 0;            /* infinite */

	Sleep(minutes * 60000);
	raise(SIGINT);
	return 0;
}

#else
void *countdown_thread(void *pminutes) {
	uint32 minutes = *(uint32 *)pminutes;

	if (minutes > 0xffffffff / 60)
		minutes = 0xffffffff / 60;   /* infinite */

	sleep(minutes * 60);
	raise(SIGINT);
	return NULL;
}
#endif

/*--------------------------------------------------------------------*/
int getfactor_integer(char *inputstring, msieve_obj **obj, int innum_threads) {
	char buf[500];
	uint32 seed1, seed2;
        char *savefile_name = NULL;
	char *logfile_name = NULL;
        //	char *infile_name = "worktodo.ini";
	char *nfs_fbfile_name = NULL;
	uint32 flags;
        //	char manual_mode = 0;
        //	int i;
        int32 deadline = 0;
	uint32 max_relations = 0;
	enum cpu_type cpu;
	uint32 cache_size1; 
	uint32 cache_size2; 
	uint32 num_threads = innum_threads;
	uint32 which_gpu = 0;
	const char *nfs_args = NULL;
        
	get_cache_sizes(&cache_size1, &cache_size2);
	cpu = get_cpu_type();

        typedef void (*sighandler_t)(int);
        sighandler_t oldsighandler;
        oldsighandler = signal(SIGINT, handle_signal);
	if ( oldsighandler  == SIG_ERR) {
	        printf("could not install handler on SIGINT\n");
	        return -1;
	}
	if (signal(SIGTERM, handle_signal) == SIG_ERR) {
	        printf("could not install handler on SIGTERM\n");
	        return -1;
	}     
#ifdef HAVE_MPI
	{
		int32 level;
		if ((i = MPI_Init_thread(&argc, &argv,
				MPI_THREAD_FUNNELED, &level)) != MPI_SUCCESS) {
			printf("error %d initializing MPI, aborting\n", i);
			MPI_Abort(MPI_COMM_WORLD, i);
		}
	}
#endif

	flags = MSIEVE_FLAG_USE_LOGFILE;

        flags &= ~(MSIEVE_FLAG_USE_LOGFILE |
                   MSIEVE_FLAG_LOG_TO_STDOUT);

        
        //	i = 1;
	buf[0] = 0;

        {
          strncpy(buf, inputstring, sizeof(buf));
        }
        
        get_random_seeds(&seed1, &seed2);

	if (deadline) {
#if defined(WIN32) || defined(_WIN64)
		DWORD thread_id;
		CreateThread(NULL, 0, countdown_thread, 
				&deadline, 0, &thread_id);
#else
		pthread_t thread_id;
		pthread_create(&thread_id, NULL, 
				countdown_thread, &deadline);
#endif
	}
        
        //        if (isdigit(buf[0]) || buf[0] == '(' ) {
          //          msieve_obj *saveobj;
        int retval =  factor_integer(buf, flags, savefile_name, 
				logfile_name, nfs_fbfile_name,
				&seed1, &seed2,
				max_relations, 
				cpu, cache_size1, cache_size2,
				num_threads, which_gpu,
                         nfs_args, obj);
          //        }
        signal(SIGINT, oldsighandler); // restore old interrupt handler
#ifdef HAVE_MPI
	MPI_Finalize();
#endif
	return retval;
}

/* free the current factorization struct. The following
   avoids a race condition in the signal handler */
void msieve_obj_free_2 (msieve_obj *obj) {
  msieve_obj *obj1;
  obj1 = obj;
  obj = NULL;
   if (obj1)
    msieve_obj_free(obj1);
}

msieve_obj * factor_from_string(char *inum, int num_threads) {
  msieve_obj *obj = NULL;
  int retval = getfactor_integer(inum, &obj, num_threads);
  if (retval == 0) obj = NULL;
  return obj;
}

msieve_factor * get_factors_from_obj(msieve_obj *obj) {
  return obj->factors;
}

int get_num_factors(msieve_factor *factors) {
  msieve_factor *factor = factors;
  int count = 0;
  while (factor != NULL) {
    factor = factor->next;
    ++count;
  }
  return count;
}

msieve_factor * get_one_factor_value(msieve_factor *factor, char *outstring, int max) {
  strncpy(outstring, factor->number, max);
  return factor->next;
}


/*
int main(int argc, char **argv) {
  //  char **output_factor_strings = NULL;
  //  output_factor_strings = (char **) malloc(sizeof(void *));
  char buf1[500];
  msieve_obj *obj = NULL;
  strncpy(buf1, argv[1], sizeof(buf1));
  if (argc == 2 ) getfactor_integer(buf1, obj);
  msieve_obj_free_2(obj);
  return 0;
}
*/
