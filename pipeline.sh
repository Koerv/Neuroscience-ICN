#!/bin/bash

function strrep {
  replaced=${1/TIMEWINDOW/$2}
  echo ${replaced//FREQUENCYBAND/$3}
}

# Define raw file_paths
raw_data_file='data/raw/stim_probe_category_ON_meanFREQUENCYBAND_LFP_bipolar_noscram_artif_brodmann_wTIMEWINDOW_FREQUENCYBAND_resppositive.pkl'
raw_filtered_data_file='data/filtered/TIMEWINDOW_FREQUENCYBAND.pkl'
raw_partitioned_data_file='data/partitioned/TIMEWINDOW_FREQUENCYBAND.pkl'
raw_grid_search_file='data/grid_search/TIMEWINDOW_FREQUENCYBAND.pkl'
raw_ensemble_file='data/ensemble/TIMEWINDOW_FREQUENCYBAND.pkl'

# Initialise the values of time windows and frequency bands researched
time_windows="50 150 250"
frequency_bands="theta alpha beta lowgamma highgamma"

# Set cross-validation parameters
partitions=10
iterations=10

# Set grid search parameters
trials=10000

# Set ensemble construction parameters
best_proportion=0.1
used_proportion=0.1

# Iterate through each possible time window
for time_window in $time_windows
do

  # Iterate through each possible frequency band
  for frequency_band in $frequency_bands
  do

    # Construct file names specific to the current time window and freqeuncy
    # band
    data_file=$(strrep $raw_data_file $time_window $frequency_band)
    filtered_data_file=$(strrep $raw_filtered_data_file $time_window $frequency_band)
    partitioned_data_file=$(strrep $raw_partitioned_data_file $time_window $frequency_band)
    grid_search_file=$(strrep $raw_grid_search_file $time_window $frequency_band)
    ensemble_file=$(strrep $raw_ensemble_file $time_window $frequency_band)

    # Split file name and extension
    partitioned_data_file_name=${partitioned_data_file%.*}
    partitioned_data_file_extension=${partitioned_data_file##*.}

    # Filter the raw data by classes
    printf '# Pipeline ($d, $s): Filtering data by classes' $time_window $frequency_band
    python ./filter_by_class.py $data_file $filtered_data_file 10 20 30 40 50
    printf '\n\n'

    # Descriptive analysis of the data set. This is not necessaryly a part of
    # the pipeline, as the data set does not change, but it is still currently
    # included for the purposes of clarity.
    printf '# Pipeline ($d, $s): Descriptive analysis\n' $time_window $frequency_band
    python ./descriptive_analysis.py $filtered_data_file
    printf '\n'

    # Data partitioning. We use stratified k-fold cross-validation N times.
    printf '# Pipeline ($d, $s): Partitioning data %d times into %d equal sets\n' $time_window $frequency_band $iterations $partitions
    for (( i=1; i<=iterations; i++ ))
    do
        python ./partition_data.py $filtered_data_file $partitioned_data_file_name'-'$i'.'$partitioned_data_file_extension $partitions --even
    done
    printf '\n'

    # Classification and grid search
    printf '# Pipeline ($d, $s): Classification and grid search\n' $time_window $frequency_band
    python ./classify.py $partitioned_data_file $grid_search_file $partitions $iterations $trials
    printf '\n'

    # Ensemble construction, classification and scoring
    printf '# Pipeline ($d, $s): Ensemble construction, classification and scoring\n' $time_window $frequency_band
    python ./ensemble.py $partitioned_data_file $grid_search_file $ensemble_file $partitions $iterations $best_proportion $used_proportion
    printf '\n'

  done

done

# TODO: Implement data integration and results plotting
