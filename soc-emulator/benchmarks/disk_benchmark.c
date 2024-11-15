#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Function to run the disk benchmark test
int main() {
    const char *file_path = "/tmp/disk_test.tmp";
    FILE *file = fopen(file_path, "w");
    if (file == NULL) {
        printf("0\n");
        return 1;
    }

    const int write_iterations = 100000; // Number of lines to write
    const char *data = "This is a test line for disk I/O benchmark.\n";
    size_t data_size = sizeof("This is a test line for disk I/O benchmark.\n") - 1;
    long bytes_written = 0;

    // Measure the time taken to perform the write operations
    clock_t start = clock();
    for (int i = 0; i < write_iterations; i++) {
        bytes_written += fwrite(data, 1, data_size, file);
    }
    clock_t end = clock();

    fclose(file);
    remove(file_path); // Clean up the temporary file

    // Calculate elapsed time in seconds
    double elapsed_time = (double)(end - start) / CLOCKS_PER_SEC;

    // Calculate the disk I/O throughput in MB/s
    double disk_io_throughput = (bytes_written / (1024.0 * 1024.0)) / elapsed_time;

    // Output the throughput in MB/s
    printf("%.2f\n", disk_io_throughput);
    return 0;
}
