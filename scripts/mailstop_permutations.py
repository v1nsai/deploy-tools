import pandas as pd
import re

'''Generate all possible Mail Stop permutations given a list of substitutions per character'''

mail_stops = pd.read_excel('/Users/doctor_ew/Downloads/Mail Stops for Permutations.xlsx', sheet_name=0)
character_permutations = pd.read_excel('/Users/doctor_ew/Downloads/Mail Stops for Permutations.xlsx', sheet_name=1)
known_permutations = pd.DataFrame(columns=['Mail Stop', 'Known Permutations'])

def get_weak_letters_for_stop(stop, char, errors):
    '''Get a dict where key=char index in stop and value=similar chars to be subbed in'''
    weak_letters = {}
    for i,s in enumerate(stop):
        if s == char:
            for e in errors:
                if i in weak_letters:
                    weak_letters[i] = weak_letters[i] + [e]
                else:
                    weak_letters[i] = [e]

    return weak_letters

def perms_for_character(index, badchars, combos, stop, generated_for_index):
    '''Recursively generate all permutations for a single replaceable char'''
    if not generated_for_index.setdefault(index, False):
        for badchars in weak_letters[index]:
            for badchar in badchars:
                new_stop = list(stop)
                new_stop[index] = badchar
                combos.add(''.join(new_stop))
        generated_for_index[index] = True
        for idx, chars in weak_letters.items():
            if idx == index:
                continue
            combos = perms_for_character(idx, chars, combos, new_stop, generated_for_index)

    return combos

def get_details(stop_row, char_row):
    stop = list(stop_row['Mail Stop'])
    char = str(char_row['Character'])
    errors = str(char_row['Errors'])
    if type(errors) != 'list':
        errors = re.split(r',\s?', errors)
    else:
        errors
    
    return stop, char, errors

if __name__ == '__main__':
    for dummy, stop_row in mail_stops.iterrows():
        weak_letters = {}
        permutations = set()
        for dummy2, char_row in character_permutations.iterrows():
            stop, char, errors = get_details(stop_row, char_row)
            w_l = get_weak_letters_for_stop(stop, char, errors)
            for index, replacements in w_l.items():
                weak_letters[index] = replacements

        state = dict(weak_letters)
        for index, chars in weak_letters.items():
            state[index] = stop[index]

        combos = set()
        for index, badchars in weak_letters.items():
            permutations = perms_for_character(index, badchars, combos, stop, dict())

        row = {}
        row['Mail Stop'] = ''.join(stop)
        row['Known Permutations'] = ','.join(permutations)
        new_row = pd.DataFrame(row, index=[0])
        known_permutations = pd.concat([known_permutations, new_row], ignore_index=True)

        known_permutations.to_csv('known_permutations.csv', index=False)