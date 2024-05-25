import matplotlib.pyplot as plt
import pandas as pd
from datetime import datetime
import numpy as np

# Mapping Polish month names to numbers
month_map = {
    'sty': '01',
    'lut': '02',
    'mar': '03',
    'kwi': '04',
    'maj': '05',
    'cze': '06',
    'lip': '07',
    'sie': '08',
    'wrz': '09',
    'paź': '10',
    'lis': '11',
    'gru': '12'
}

# Custom function to parse date strings with Polish month names
def parse_date(date_str):
    date_parts = date_str.split()
    date_parts[2] = month_map[date_parts[2]]
    formatted_date_str = ' '.join(date_parts[1:5]) + ' ' + date_parts[5]
    return datetime.strptime(formatted_date_str, '%d %m %H:%M:%S %Y CEST')

def save_przyrost(ile):
    # Pobranie obecnego czasu
    current_time = datetime.now()

    # Formatuj datę i czas zgodnie z wymaganiami
    formatted_time = current_time.strftime('%d %m %Y %H:%M:%S')

    # Otwieranie pliku do zapisu
    with open('zmiana.out', 'a') as file:
        # Zapis do pliku w formacie 'dd mm yyyy HH:MM:SS, number'
        file.write(f'{formatted_time}, {ile:.0f}\n')

# Read the file content
file_path = 'wyniki.out'  # Replace with the path to your file
data = []

with open(file_path, 'r', encoding='utf-8') as file:
    lines = file.readlines()
    for line in lines[1:]:  # Skip header
        date_str, suma, _, _ = line.split(',')
        date_obj = parse_date(date_str)
        data.append([date_obj, int(suma)])

# Convert to DataFrame
df = pd.DataFrame(data, columns=['Date', 'Suma'])

# Convert datetime to numerical values for regression
df['Date_num'] = df['Date'].apply(datetime.timestamp)

# Perform linear regression
coefficients = np.polyfit(df['Date_num'], df['Suma'], 1)
poly = np.poly1d(coefficients)

# Perform pol2 regression
coefficients2 = np.polyfit(df['Date_num'], df['Suma'], 2)
poly2 = np.poly1d(coefficients2)

# Define the extended range for the trend line
start_date = datetime(2024, 5, 18)
end_date = datetime(2024, 6, 6)
extended_dates = pd.date_range(start=start_date, end=end_date, freq='D')

# Convert extended dates to numerical values
extended_dates_num = extended_dates.map(datetime.timestamp)

# Calculate the trend values for the extended range
extended_trend = poly(extended_dates_num)
extended_trend2 = poly2(extended_dates_num)

# Plotting the data
plt.figure(figsize=(10, 6))
plt.plot(df['Date'], df['Suma'], marker='o', label='Suma zarejestrowanych')
plt.plot(extended_dates, extended_trend, label='Aproksymacja liniowa', linestyle='--', color='red')
plt.plot(extended_dates, extended_trend2, label='Aproksymacja kwadratowa', linestyle='--', color='green')

# Display the linear regression equation on the plot
## Extract the slope and intercept
slope, intercept = coefficients
slope *= 24*3600
plt.text(datetime(2024, 5, 17, 18), 41000, f'Przyrost dzienny:  +{slope:.0f}  /  [dzień]', fontsize=12, color='red')
save_przyrost(slope)

# Add the logo text
plt.text(datetime(2024, 6, 2, 23, 40), 11000, '@linux_wins', fontsize=9, color='blue', weight='bold')

plt.xlabel('Data')
plt.ylabel('Suma')
plt.title('Liczba zarejstrowanych wyborców za granicą oraz ich aproksymacja na przestrzeni czasu zapisów', fontweight='bold')
plt.grid(True)
plt.legend()
plt.xticks(rotation=45)
plt.tight_layout()

# Save the plot as a PNG file
plt.savefig('wyniki.png')

#plt.show()


