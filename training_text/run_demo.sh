#!/bin/bash
function stopwatch {
  cmd=$1
  name=$2
  if [[ -z $name ]]; then
    name=0
  fi

  stopwatch_time="STOPWATCH_TIME_${name}"  
  stopwatch_start="STOPWATCH_START_${name}"  

  case $cmd in
    reset)
      unset $stopwatch_time 
      unset $stopwatch_start 
    ;;
    start)
      if [[ ! ${!stopwatch_time} ]]; then
        export $stopwatch_time=0
      fi
      if [[ ! ${!stopwatch_start} ]]; then
        export $stopwatch_start=$(date +%s)
      fi
    ;;
    stop)
      if [[ ${!stopwatch_start} ]]; then
          x=$stopwatch_time
          y=$stopwatch_start
          z=$(( x + $(date +%s) - y ))
          export $stopwatch_time=$z
          unset $stopwatch_start
      fi
    ;;
    display)
      if [[ ${!stopwatch_time} ]]; then
        if [[ ${!stopwatch_start} ]]; then
          x=$stopwatch_time
          y=$stopwatch_start
          seconds_to_clock $(( x + $(date +%s) - y ))
        else
          x=$stopwatch_time
          seconds_to_clock $x
        fi
      fi
    ;;
    *)
      echo "Valid functions:
  start
  stop
  display
  reset"
    ;;
  esac
}
function seconds_to_clock {
  dt=$1
  ds=$((dt % 60))
  dm=$(((dt / 60) % 60))
  dh=$((dt / 3600))
  dd=$((dt / 86400))
  printf "%d-%02d:%02d:%02d\n" $dd $dh $dm $ds
}

echo ""
echo Please see https://hpc.nih.gov/apps/rosetta for a full
echo explanation of Rosetta
echo ""
echo This demo should take about 5 minutes on a single core
echo ""

[[ -n $ROSETTA3_DB ]] || { echo 'You need to load the rosetta module first!' ; exit 1; }

echo "Running with $LOADEDMODULES
"

# Start stopwatch
stopwatch reset 0; stopwatch start 0
# Set global paths
demo=`pwd`

# Abinitio
stopwatch reset 1; stopwatch start 1
cd $demo/Abinitio
rm -f 1l2y_silent.out abinitio.log score.fsc
echo -- Fold a protein sequence, output as silentfile
AbinitioRelax @flags > abinitio.log
echo -n "  -- "; stopwatch display 1

# Backrub
stopwatch reset 1; stopwatch start 1
cd $demo/Backrub
rm -f score.sc 1MFG_0001_last.pdb 1MFG_0001_low.pdb 1MFG_0001.pdb 1MFGft_0001_last.pdb 1MFGft_0001_low.pdb 1MFGft_0001.pdb backrub_advanced.log backrub_basic.log
echo -- Run backrub protocol on 1mfg
backrub @flags_basic > backrub_basic.log
echo -- Run backrub protocol on 1mfg again with more advanced options
backrub @flags_advanced > backrub_advanced.log
echo -n "  -- "; stopwatch display 1

# ClassicRelax
stopwatch reset 1; stopwatch start 1
cd $demo/ClassicRelax
rm -rf relax_classic.log relax_fast.log S_1029_classic_0001.pdb S_1029_fast_0001.pdb score_classic.sc score_fast.sc
echo -- Relax a structure
relax @flags_classic > relax_classic.log
echo -- Relax a structure in a more efficient way
relax @flags_fast > relax_fast.log
echo -n "  -- "; stopwatch display 1

# Docking
stopwatch reset 1; stopwatch start 1
cd $demo/Docking
rm -f 1brs_0001.pdb docking.log score.fasc
echo -- Dock two proteins as rigid bodies
docking_protocol @flags > docking.log
echo -n "  -- "; stopwatch display 1

# Fixed Backbone Design
stopwatch reset 1; stopwatch start 1
echo -- Optimize sidechain-rotamer placement on a fixed backbone
cd $demo/FixedBackboneDesign
rm -f 1l2y_centroid_0001.pdb 1l2y_fa_0001.pdb 1l2y_fa_r_0001.pdb fixbb_centroid.log fixbb_fullatom.log fixbb_fullatom_resfile.log score_fa_r.sc score_fa.sc score.sc
echo -- Run with centroid only
fixbb @flags_centroid > fixbb_centroid.log
echo -- Run will full atom
fixbb @flags_fullatom > fixbb_fullatom.log
echo -- Run full atom again, except now mutate residues based on resfile
fixbb @flags_fullatom_resfile > fixbb_fullatom_resfile.log
echo -n "  -- "; stopwatch display 1

# FlexPepDocking
stopwatch reset 1; stopwatch start 1
cd $demo/FlexPepDock
rm -f 1AWR.ex_basic_0001.pdb 1AWR.ex_lowres_0001.pdb FlexPepDocking_basic.log FlexPepDocking_lowres.log score_basic.sc score_lowres.sc
echo "-- Dock a 6-mer peptide to 1awr (cyclophilin A from HIV-1 capsid) basic run"
FlexPepDocking @flags_basic > FlexPepDocking_basic.log
echo -- Dock with res 166 as anchor and add low resolution round of optimization
FlexPepDocking @flags_lowres > FlexPepDocking_lowres.log
echo -n "  -- "; stopwatch display 1

# Idealize
stopwatch reset 1; stopwatch start 1
cd $demo/Idealization
rm -f idealize.log idealize_fast.log score_fast.sc score.sc test_in_0001.pdb test_in_fast_0001.pdb
echo -- Run the idealize protocol on a pdb
idealize_jd2 @flags > idealize.log
echo -- Run the idealize protocol on a pdb with -fast option
idealize_jd2 @flags_fast > idealize_fast.log
echo -n "  -- "; stopwatch display 1

# Loop Modeling
stopwatch reset 1; stopwatch start 1
cd $demo/LoopModeling
rm -f 4fxn_4fxn.start_0001_0001.pdb 4fxn_score.sc loopmodel.log
echo -- Rebuild loops on a CA/CB model
loopmodel @flags > loopmodel.log
echo -n "  -- "; stopwatch display 1

# Metalloprotein abrelax
stopwatch reset 1; stopwatch start 1
cd $demo/Metalloprotein_abrelax
rm -rf jumps.log jumps_pre.log LL1dsvA.out metalloprotein_abrelax.log S_00000001.pdb score.fsc
echo -- Run abinitio relax on a protein with a single zinc atom, highly constrained
AbinitioRelax @flags > metalloprotein_abrelax.log
echo -n "  -- "; stopwatch display 1

# Scoring
stopwatch reset 1; stopwatch start 1
cd $demo/Scoring
rm -f score.log score.sc score_s.log score_s.sc
echo -- Generate a score file for a pdb
score_jd2 @flags > score.log
echo -- Generate a score for a silentfile, using a non-standard weights file
score_jd2 @flags_s > score_s.log
echo -n "  -- "; stopwatch display 1

# SilentFileTools
stopwatch reset 1; stopwatch start 1
cd $demo/SilentFileTools
rm -f combine.log extract.log test.silent.out
echo -- Combine a set of pdbs and write to a binary silent file
combine_silent @flag_combine > combine.log
echo -- Create pdbs from a binary silent file
extract_pdbs @flag_extract > extract.log
echo -n "  -- "; stopwatch display 1

# Overall time
echo -n "-- "; stopwatch display 0
