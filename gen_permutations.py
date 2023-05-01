import pandas as pd
import re

mail_stops = pd.read_excel('/Users/doctor_ew/Downloads/Mail Stops for Permutations.xlsx', sheet_name=0)
character_permutations = pd.read_excel('/Users/doctor_ew/Downloads/Mail Stops for Permutations.xlsx', sheet_name=1)
known_permutations = pd.DataFrame(columns=['Mail Stop', 'Known Permutations'])

for dummy, stop_row in mail_stops.iterrows():
    # weak_letters = {}
    weak_letters = dict()
    permutations = set()
    for dummy2, char_row in character_permutations.iterrows():
        stop = list(stop_row['Mail Stop'])
        char = str(char_row['Character'])
        try:
            errors = re.split(r',\s?', char_row['Errors'])
        except:
            if type(errors) != 'list':
                list(errors)

        for i,s in enumerate(stop):
            if s == char:
                if s in weak_letters:
                    weak_letters[s] = weak_letters[s] + [i]
                else:
                    weak_letters[s] = [i]
            
    for letter,indices in weak_letters.items():
        for ix in indices:
            
    print()



    row = {}
    row['Mail Stop'] = ''.join(stop)
    row['Known Permutations'] = ','.join(permutations)
    new_row = pd.DataFrame(row, index=[0])
    known_permutations = pd.concat([known_permutations, new_row], ignore_index=True)

# known_permutations.to_csv('known_permutations.csv', index=False)

        # for e in errors:
        #     perm = list(stop)
        #     perm[i] = e
        #     permutations.add(''.join(perm).strip())