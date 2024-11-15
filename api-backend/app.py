from flask import Flask, request, jsonify
import psycopg2
import os

app = Flask(__name__)

# Database connection
conn = psycopg2.connect(
    host=os.getenv("POSTGRES_HOST", "postgres"),
    port=os.getenv("POSTGRES_PORT", "5432"),
    database=os.getenv("POSTGRES_DB", "soc_data"),
    user=os.getenv("POSTGRES_USER", "user"),
    password=os.getenv("POSTGRES_PASSWORD", "pass")
)
cursor = conn.cursor()

# Create table if it doesn't exist
cursor.execute("""
    CREATE TABLE IF NOT EXISTS soc_metrics (
        id SERIAL PRIMARY KEY,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        cpu_usage FLOAT,
        memory_usage FLOAT,
        disk_io FLOAT,
        config_name TEXT
    )
""")
conn.commit()

@app.route('/api/store_metric', methods=['POST'])
def store_metric():
    data = request.get_json()
    cpu_usage = data.get('cpu_usage')
    memory_usage = data.get('memory_usage')
    disk_io = data.get('disk_io')
    config_name = data.get('config_name', 'default')

    cursor.execute("""
        INSERT INTO soc_metrics (cpu_usage, memory_usage, disk_io, config_name)
        VALUES (%s, %s, %s, %s)
    """, (cpu_usage, memory_usage, disk_io, config_name))
    conn.commit()
    return jsonify({'status': 'success'}), 200

@app.route('/api/get_metrics', methods=['GET'])
def get_metrics():
    start = request.args.get('start')
    end = request.args.get('end')
    query = "SELECT * FROM soc_metrics"
    params = []

    if start and end:
        query += " WHERE timestamp BETWEEN %s AND %s"
        params.extend([start, end])

    cursor.execute(query, params)
    records = cursor.fetchall()
    metrics = []
    for row in records:
        metrics.append({
            'id': row[0],
            'timestamp': row[1],
            'cpu_usage': row[2],
            'memory_usage': row[3],
            'disk_io': row[4],
            'config_name': row[5]
        })
    return jsonify(metrics), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
