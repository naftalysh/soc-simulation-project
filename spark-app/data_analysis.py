from pyspark.sql import SparkSession
from pyspark.sql.functions import avg, max, min
import os

def main():
    # Create Spark session
    spark = SparkSession.builder \
        .appName("SoCDataAnalysis") \
        .getOrCreate()
    
    # JDBC connection properties
    jdbc_url = "jdbc:postgresql://{host}:{port}/{db}".format(
        host=os.getenv("POSTGRES_HOST", "postgres"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        db=os.getenv("POSTGRES_DB", "soc_data")
    )
    connection_properties = {
        "user": os.getenv("POSTGRES_USER", "user"),
        "password": os.getenv("POSTGRES_PASSWORD", "pass"),
        "driver": "org.postgresql.Driver"
    }

    # Read data from PostgreSQL
    soc_metrics_df = spark.read.jdbc(
        url=jdbc_url,
        table="soc_metrics",
        properties=connection_properties
    )
    
    # Perform data analysis
    cpu_usage_stats = soc_metrics_df.agg(
        avg("cpu_usage").alias("avg_cpu_usage"),
        max("cpu_usage").alias("max_cpu_usage"),
        min("cpu_usage").alias("min_cpu_usage")
    ).collect()[0]
    
    memory_usage_stats = soc_metrics_df.agg(
        avg("memory_usage").alias("avg_memory_usage"),
        max("memory_usage").alias("max_memory_usage"),
        min("memory_usage").alias("min_memory_usage")
    ).collect()[0]
    
    # Print results
    print("CPU Usage Statistics:")
    print(f"Average CPU Usage: {cpu_usage_stats['avg_cpu_usage']}")
    print(f"Max CPU Usage: {cpu_usage_stats['max_cpu_usage']}")
    print(f"Min CPU Usage: {cpu_usage_stats['min_cpu_usage']}")
    
    print("Memory Usage Statistics:")
    print(f"Average Memory Usage: {memory_usage_stats['avg_memory_usage']}")
    print(f"Max Memory Usage: {memory_usage_stats['max_memory_usage']}")
    print(f"Min Memory Usage: {memory_usage_stats['min_memory_usage']}")
    
    # Create the 'soc_analysis_results' table if it doesn't exist
    spark.sql("""
        CREATE TABLE IF NOT EXISTS soc_analysis_results (
            metric STRING,
            average DOUBLE,
            maximum DOUBLE,
            minimum DOUBLE
        )
    """)
    
    # Write results back to PostgreSQL
    results_df = spark.createDataFrame([
        ("cpu", cpu_usage_stats['avg_cpu_usage'], cpu_usage_stats['max_cpu_usage'], cpu_usage_stats['min_cpu_usage']),
        ("memory", memory_usage_stats['avg_memory_usage'], memory_usage_stats['max_memory_usage'], memory_usage_stats['min_memory_usage'])
    ], ["metric", "average", "maximum", "minimum"])
    
    results_df.write.jdbc(
        url=jdbc_url,
        table="soc_analysis_results",
        mode="overwrite",
        properties=connection_properties
    )
    
    # Stop Spark session
    spark.stop()

if __name__ == "__main__":
    main()
