/* The selected MAME fork leaves one optional VVF stats call unguarded. */
#if defined(VVF_STATS) && (VVF_STATS == 0)
#define print_color_stats(...) ((void)0)
#endif
