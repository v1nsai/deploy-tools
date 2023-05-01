import pandas as pd
import re
import itertools

mail_stops = pd.read_excel('/Users/doctor_ew/Downloads/Mail Stops for Permutations.xlsx', sheet_name=0)
character_permutations = pd.read_excel('/Users/doctor_ew/Downloads/Mail Stops for Permutations.xlsx', sheet_name=1)
known_permutations = pd.DataFrame(columns=['Mail Stop', 'Known Permutations'])

for index, stop_row in mail_stops.iterrows():
    # weak_letters = {}
    permutations = set()
    for idx, char_row in character_permutations.iterrows():
        stop = list(stop_row['Mail Stop'])
        char = str(char_row['Character'])
        try:
            errors = re.split(r',\s?', char_row['Errors'])
        except:
            if type(errors) != 'list':
                list(errors)

        if char not in stop:
            continue

        for i,s in enumerate(stop):
            if s == char:
                for e in errors:
                    perm = list(stop)
                    perm[i] = e
                    permutations.add(''.join(perm).strip())

    row = {}
    row['Mail Stop'] = ''.join(stop)
    row['Known Permutations'] = ','.join(permutations)
    new_row = pd.DataFrame(row, index=[0])
    known_permutations = pd.concat([known_permutations, new_row], ignore_index=True)
    print()

known_permutations.to_csv('known_permutations.csv', index=False)

