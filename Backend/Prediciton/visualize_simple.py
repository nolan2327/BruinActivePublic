import pandas as pd
import matplotlib.pyplot as plt
from sklearn.metrics import mean_absolute_error
import json
import os

USE_SAMPLE = True  # flip to False if you want to connect to MongoDB

if USE_SAMPLE:
    with open("sample_data.json", "r") as f:
        data = json.load(f)
    df = pd.DataFrame(data)
else:
    from pymongo import MongoClient
    client = MongoClient("_your_mongodb_connection_string_")
    db = client["_your_database_name_"]
    col = db["_your_collection_name_"]
    df = pd.DataFrame(list(col.find()))

# Parse time
df['timestamp'] = pd.to_datetime(df['time_collected'])
df['hour'] = df['timestamp'].dt.hour
df['weekday'] = df['timestamp'].dt.weekday
df['is_weekend'] = df['weekday'] >= 5
df['population'] = df['total_population']

# Split data
weekday_df = df[~df['is_weekend']]
weekend_df = df[df['is_weekend']]

# Compute average population by hour
weekday_avg = weekday_df.groupby('hour')['population'].mean()
weekend_avg = weekend_df.groupby('hour')['population'].mean()

# Predict population for each row using group average
df['predicted'] = df.apply(
    lambda row: weekend_avg[row['hour']] if row['is_weekend'] else weekday_avg[row['hour']],
    axis=1
)

# Calculate MAE
if not weekday_df.empty:
    mae_weekday = mean_absolute_error(
        weekday_df['population'],
        weekday_df['hour'].map(weekday_avg)
    )
    print(f"Weekday MAE: {mae_weekday:.2f}")

if not weekend_df.empty:
    mae_weekend = mean_absolute_error(
        weekend_df['population'],
        weekend_df['hour'].map(weekend_avg)
    )
    print(f"Weekend MAE: {mae_weekend:.2f}")

# Plot
plt.figure(figsize=(12, 6))
plt.scatter(df['hour'], df['population'], alpha=0.3, label='Actual (raw)', color='blue')
if not weekday_avg.empty:
    plt.plot(weekday_avg.index, weekday_avg.values, label='Weekday Average', color='red', linewidth=2)
if not weekend_avg.empty:
    plt.plot(weekend_avg.index, weekend_avg.values, label='Weekend Average', color='green', linewidth=2)

plt.xlabel('Hour of Day')
plt.ylabel('Gym Total Population')
plt.title('Gym Hourly Population Trends (Sample Data)')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()
