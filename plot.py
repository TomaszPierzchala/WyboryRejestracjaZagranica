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

cutoff_date = datetime(2024, 5, 27).timestamp()
filtered_df = df[df['Date_num'] < cutoff_date]


# Perform linear regression
coefficients = np.polyfit(filtered_df['Date_num'], filtered_df['Suma'], 1)
poly = np.poly1d(coefficients)

# Perform polN regression
coefficientsN = np.polyfit(df['Date_num'], df['Suma'], 3)
polyN = np.poly1d(coefficientsN)
coefNdiff = np.array([3.*coefficientsN[0], 2.*coefficientsN[1], coefficientsN[2]])
polyNdiff = np.poly1d(coefNdiff)

# Define the extended range for the trend line
start_date = datetime(2024, 5, 18)
end_date = datetime(2024, 6, 6)
extended_dates = pd.date_range(start=start_date, end=end_date, freq='D')

# Convert extended dates to numerical values
extended_dates_num = extended_dates.map(datetime.timestamp)

# Calculate the trend values for the extended range
extended_trend = poly(extended_dates_num)
extended_trendN = polyN(extended_dates_num)

# Plotting the data
plt.figure(figsize=(12, 7))
plt.plot(df['Date'], df['Suma'], marker='o', label='Suma zarejestrowanych')
plt.plot(extended_dates, extended_trend, label='Aproksymacja liniowa do dnia 2024-05-27', linestyle='--', color='red')
plt.plot(extended_dates, extended_trendN, label='Aproksymacja wielomianowa trzeciego stopnia', linestyle='--', color='green')
plt.axvline(datetime(2024, 6, 4, 23, 59), ymax=0.95, color='blue', linestyle='-', linewidth=2, label='Koniec rejestracji o 23:59 2024-06-04')
plt.axhline(y=106397, xmin=0.4, xmax=0.96, color='orange', linestyle='-', linewidth=2, label='106 397 - liczba rejestracji w wyborach do PE 2019')


# Display the polinomial regression equation on the plot
cslope = polyNdiff(df['Date_num'].max()) * 24*3600
plt.text(datetime(2024, 5, 17, 17), 62500, f'przyrost dzienny z aproksymacji kubicznej:  +{cslope:.0f}  /  [dzień]', fontsize=12, color='green', fontweight='bold')

# Add the logo text
plt.text(datetime(2024, 6, 1, 4), 12000, '@linux_wins', fontsize=9, color='blue', weight='bold')

# Dostosowanie zakresu osi Y
plt.ylim(10_000, 120_000 )
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


