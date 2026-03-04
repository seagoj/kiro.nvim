When KiroBuffer is invoked without an open file in the buffer the NO_FILE error is redundant with the "Cannot add empty
or non-string message to history" error. Remove the NO_FILE error.
