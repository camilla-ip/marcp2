#!/usr/bin/env python

import h5py, numpy as np, os, sys

if len(sys.argv) < 4:
    print('Usage:   poremeta.py runname fast5_path keeptype')
    print('         Extract a table of attributes and values from a fast5 file.')
    print('Options:')
    print('         keeptype : "all" to extract all attributes or "paramsonly" for the setup or run-related attributes only')
    print('')
    sys.exit(1)
runname = sys.argv[1]
fast5_path = os.path.expandvars(sys.argv[2])
keeptype = sys.argv[3].lower()
if keeptype not in ['all', 'paramsonly']:
    print('Error: invalid keeptype ({0})'.format(keeptype))
    sys.exit(2)

paramL = [
    "Analyses/Basecall_2D_000/dragonet version",
    "Analyses/Basecall_2D_000/version",
    "Analyses/Basecall_2D_000/name",
    "Analyses/Basecall_2D_000/chimaera version",
    "Analyses/Basecall_2D_000/Configuration/aggregator/report",
    "Analyses/Basecall_2D_000/Configuration/aggregator/sections",
    "basecall_1d_template,basecall_1d_complement,hairpin_align,basecall_2d",
    "Analyses/Basecall_2D_000/Configuration/basecall_1d/ignore_penalty",
    "Analyses/Basecall_2D_000/Configuration/basecall_1d/outlier_prob",
    "Analyses/Basecall_2D_000/Configuration/basecall_1d/scale_iterations",
    "Analyses/Basecall_2D_000/Configuration/basecall_1d/remove_iterations",
    "Analyses/Basecall_2D_000/Configuration/basecall_1d/ignore_prob",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/trans_max_diff",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/trans_fmin",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/c03",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/chunk_size",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/band_size",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/trans_min_diff",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/trans_unity_diff",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/window_size",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/min_mean_qscore",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/trans_mod",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/use_sd",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/c01",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/c02",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/trans_fmax",
    "Analyses/Basecall_2D_000/Configuration/basecall_2d/c04",
    "Analyses/Basecall_2D_000/Configuration/general/recipe",
    "Analyses/Basecall_2D_000/Configuration/general/template_model",
    "Analyses/Basecall_2D_000/Configuration/general/max_events",
    "Analyses/Basecall_2D_000/Configuration/general/min_events",
    "Analyses/Basecall_2D_000/Configuration/general/barcoding_path",
    "Analyses/Basecall_2D_000/Configuration/general/default_model_path",
    "Analyses/Basecall_2D_000/Configuration/general/complement_model",
    "Analyses/Basecall_2D_000/Configuration/general/sampling_rate",
    "Analyses/Basecall_2D_000/Configuration/general/config",
    "Analyses/Basecall_2D_000/Configuration/general/workflow_name",
    "Analyses/Basecall_2D_000/Configuration/general/counter",
    "Analyses/Basecall_2D_000/Configuration/general/model_path",
    "Analyses/Basecall_2D_000/Configuration/general/model_type",
    "Analyses/Basecall_2D_000/Configuration/hairpin_align/boundary_value_2d",
    "Analyses/Basecall_2D_000/Configuration/hairpin_align/skip_2d_for_bad_runs",
    "Analyses/Basecall_2D_000/Configuration/hairpin_align/max_ratio",
    "Analyses/Basecall_2D_000/Configuration/hairpin_align/gap_penalty",
    "Analyses/Basecall_2D_000/Configuration/hairpin_align/max_events",
    "Analyses/Basecall_2D_000/Configuration/hairpin_align/min_ratio",
    "Analyses/Basecall_2D_000/Configuration/hairpin_align/min_events",
    "Analyses/Basecall_2D_000/Configuration/post_processing/tstat_threshold",
    "Analyses/Basecall_2D_000/Configuration/post_processing/stutter_divisor",
    "Analyses/Basecall_2D_000/Configuration/post_processing/stutter_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing/use_post_processing",
    "Analyses/Basecall_2D_000/Configuration/post_processing/stutter_threshold",
    "Analyses/Basecall_2D_000/Configuration/post_processing/tstat_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing/posterior_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.3000Hz/tstat_threshold",
    "Analyses/Basecall_2D_000/Configuration/post_processing.3000Hz/stutter_divisor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.3000Hz/stutter_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.3000Hz/use_post_processing",
    "Analyses/Basecall_2D_000/Configuration/post_processing.3000Hz/stutter_threshold",
    "Analyses/Basecall_2D_000/Configuration/post_processing.3000Hz/tstat_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.3000Hz/posterior_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.5000Hz/tstat_threshold",
    "Analyses/Basecall_2D_000/Configuration/post_processing.5000Hz/stutter_divisor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.5000Hz/stutter_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.5000Hz/use_post_processing",
    "Analyses/Basecall_2D_000/Configuration/post_processing.5000Hz/stutter_threshold",
    "Analyses/Basecall_2D_000/Configuration/post_processing.5000Hz/tstat_factor",
    "Analyses/Basecall_2D_000/Configuration/post_processing.5000Hz/posterior_factor",
    "Analyses/Basecall_2D_000/Configuration/recipes/basecall",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/trim_end",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/trim_front",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/max_pt_search_len",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/pt_window",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/mad_threshold",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/min_peak_dur",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/min_pt_dur",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/peak_threshold",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/mode",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/pt_drop",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/trim_hairpin",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/da_min_pt_dur",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/min_events",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/abasic_range_backup",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/first_n",
    "Analyses/Basecall_2D_000/Configuration/split_hairpin/da_min_peak_dur",
    "Analyses/EventDetection_000/name",
    "Analyses/EventDetection_000/version",
    "Analyses/EventDetection_000/Configuration/abasic_detection/min_sample_size",
    "Analyses/EventDetection_000/Configuration/abasic_detection/max_sample_size",
    "Analyses/EventDetection_000/Configuration/abasic_detection/threshold_factor",
    "Analyses/EventDetection_000/Configuration/abasic_detection/first_peak_min_length",
    "Analyses/EventDetection_000/Configuration/abasic_detection/secondary_peak_min_length",
    "Analyses/EventDetection_000/Configuration/abasic_detection/secondary_peak_factor",
    "Analyses/EventDetection_000/Configuration/abasic_detection/secondary_peak_factor_relative_to_median",
    "Analyses/EventDetection_000/Configuration/abasic_detection/must_go_below_median_before",
    "Analyses/EventDetection_000/Configuration/event_detection/mode",
    "Analyses/EventDetection_000/Configuration/event_detection/peak_detector",
    "Analyses/EventDetection_000/Configuration/event_detection/threshold",
    "Analyses/EventDetection_000/Configuration/event_detection/window_size",
    "Analyses/EventDetection_000/Configuration/event_detection/smallest_event",
    "Analyses/EventDetection_000/Configuration/event_detection/long_threshold",
    "Analyses/EventDetection_000/Configuration/event_detection/long_window_size",
    "Analyses/EventDetection_000/Configuration/event_detection/long_smallest_event",
    "Analyses/EventDetection_000/Configuration/event_detection/limiter",
    "Analyses/EventDetection_000/Configuration/hairpin_detection/polyt_min_length",
    "Analyses/EventDetection_000/Configuration/hairpin_detection/polyt_window",
    "Analyses/EventDetection_000/Configuration/hairpin_detection/polyt_threshold_factor",
    "Sequences/Meta/version",
    "Sequences/Meta/tool",
    "Sequences/Meta/precision",
    "Sequences/Meta/numerical_encoding",
    "UniqueGlobalKey/channel_id/digitisation",
    "UniqueGlobalKey/channel_id/sampling_rate",
    "UniqueGlobalKey/tracking_id/version",
    "UniqueGlobalKey/tracking_id/protocols_version_name",
    "UniqueGlobalKey/tracking_id/version_name",
    "UniqueGlobalKey/tracking_id/exp_script_name",
    "UniqueGlobalKey/tracking_id/exp_script_purpose"
]

def Process(fast5_path):
    '''
    Open the fast5 and recursively iterate through all groups and attributes present in a fast5 file.
    The output is a tab-separated table of attribute-path and value.
    '''
    # Colllate the attribute list
    hdf = h5py.File(fast5_path, 'r')
    list_of_names = []	# Names of all groups and subgroups in the file
    hdf.visit(list_of_names.append)
    attribute = []
    for name in list_of_names:
        itemL = hdf[name].attrs.items()	# attribute name and value pairs
        for item in itemL:
            attr, val = item
            if keeptype == 'all' or (keeptype == 'paramsonly' and name+'/'+attr in paramL):
                if type(hdf[name].attrs[attr]) == np.ndarray:
                    val = ''.join(hdf[name].attrs[attr])
                val = str(val).replace('\n', '')
                attribute.append([runname, name+'/'+attr, val])
    hdf.close()
    # Print the attribute list
    print('{0}'.format('\n'.join(['\t'.join([str(x) for x in item]) for item in attribute])))

if __name__ == '__main__':
    Process(fast5_path)

