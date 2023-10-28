import pandas as pd

def interval_replace(df, col_name, interval_range):

    """
    Replace the values in a column with interval labels based on a specified interval range.

    Parameters:
    df (DataFrame): The dataframe containing the column to be replaced.

    col_name (str): The name of the column to be replaced.

    interval_range (int): The range of the intervals to be created.
    
    """

    # find the maximum value
    max_val = df[col_name].max()

    # create the first interval
    intervals = [(0, 0)]

    # determine the number of intervals needed based on the maximum value and interval range
    num_intervals = int(max_val / interval_range) + 2

    # iterate through the number of intervals and create a tuple for each interval based on the interval range
    for i in range(1, num_intervals):
        interval_start = interval_range * (i - 1) + 1
        interval_end = interval_start + (interval_range - 1)
        intervals.append((interval_start, interval_end))

    # create a list of labels for each interval
    interval_labels = ['0'] + [f"{interval[0]}-{interval[1]}" for interval in intervals[1:]]

    # create a list of the midpoint values for each interval
    midpoint_values = [(interval[0] + interval[1]) / 2 for interval in intervals]
    intervals_dict = {i: label for i, label in enumerate(interval_labels)}
    interval_labels_list = [intervals_dict[i] for i in range(len(intervals))]

    # create a list of tuples with the midpoint value and the interval label for each value in the data
    output_data = [(midpoint_values[i], interval_labels_list[i]) for value in df[col_name] for i, interval in enumerate(intervals) if value >= interval[0] and value <= interval[1]]
    df_output = pd.DataFrame(output_data, columns=[col_name, col_name + ' Bucket'])
    df.drop([col_name], axis=1, inplace=True)
    df_output = pd.concat([df, df_output], axis=1)
    
    return df_output


