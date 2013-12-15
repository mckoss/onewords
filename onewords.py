#!/usr/bin/env python
import re
import json
from itertools import permutations
from collections import Counter
from sys import stderr


regLine = re.compile(r"(?P<line>\S+)\s+(?P<word>[a-z]+)\s+\((?P<freq>\d+)\)")


def main():
    one_words = []
    patterns = Counter()

    with file("simpsons.txt") as f:
        for line in f:
            m = regLine.match(line)
            if m is None:
                continue
            word = m.group('word')

            word = word.rstrip()
            if letter_count('o', word) == 1 and \
               letter_count('n', word) == 1 and \
               letter_count('e', word) == 1:
                pattern = one_pattern(word)
                patterns[pattern] += 1
                one_words.append(word)

    for pattern, count in patterns.items():
        if count > 1:
            stderr.write("%s is ambiguous (%d ways)\n" % (pattern, count))
            for order in permutations(['o', 'n', 'e']):
                letters = list(pattern)
                for ch in order:
                    letters[letters.index('_')] = ch
                letters = ''.join(letters)
                if letters in one_words:
                    stderr.write("Removing %s\n" % letters)
                    one_words.remove(letters)

    for word in one_words:
        if word[-1:] == 's' and word[:-1] in one_words:
            stderr.write("Removing redundant plural: %s\n" % word)
            one_words.remove(word)

    print json.dumps(one_words, indent=0, separators=(',', ':'))


def one_pattern(word):
    """
    >>> one_pattern('phone')
    'ph___'
    >>> one_pattern('phenom')
    'ph___m'
    >>> one_pattern('exoxn')
    '_x_x_'
    """
    pattern = list(word)
    for ch in ('o', 'n', 'e'):
        pattern[pattern.index(ch)] = '_'
    return ''.join(pattern)


def letter_count(letter, word):
    result = 0
    for c in word:
        if letter == c:
            result += 1
    return result

if __name__ == '__main__':
    main()
