#!/usr/bin/env python2.7
# -*- coding: utf8 -*-i

from argparse import ArgumentParser
from lib.classification import classify
from sklearn import svm
from sklearn.ensemble import RandomForestClassifier

# TODO: Tune model


def run(method, data_path, partitions, iterations):

    # Define classification model based on the method passed to the algorithm
    model = None
    if method == 'svm':

        # Define model
        model = svm.SVC()

        # Define model parameters with their specified ranges
        parameters = {
            # TODO
        }

    elif method == 'random_forest':

        # Define model
        model = RandomForestClassifier(n_estimators=500)

        # Define model parameters with their specified ranges
        parameters = {
            # TODO
        }

    # Classify, predict and calculate the confusion matrix and scores
    result = classify(data_path, partitions, iterations, model)#, parameters, trials)

    # Output model results
    print(result.confusion_matrix)
    print(result.scores_per_class)
    print(result.average_scores)


if __name__ == '__main__':

    # Parse command line arguments
    PARSER = ArgumentParser()
    PARSER.add_argument('method', help='the classification method')
    PARSER.add_argument('data_path', help='the pickled data file path')
    PARSER.add_argument('partitions', help='the amount of equal sized data ' +
                        'sets created upon partitioning the data', type=int)
    PARSER.add_argument('iterations', help='the amount of times to perform ' +
                        'k-fold cross-validation', type=int)
    # PARSER.add_argument('trials', help='the amount of trials with different ' +
    #                     'randomly generated parameters')
    ARGUMENTS = PARSER.parse_args()

    # Run the data classification script
    run(ARGUMENTS.method, ARGUMENTS.data_path, ARGUMENTS.partitions,
        ARGUMENTS.iterations)