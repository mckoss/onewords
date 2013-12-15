#!/usr/bin/env python
import re
from itertools import permutations
from collections import Counter


regLine = re.compile(r"(?P<line>\S+)\s+(?P<word>\S+)\s+\((?P<freq>\d+)\)")


def main():
    one_words = {}
    patterns = Counter()

    for order in permutations(['o', 'n', 'e']):
        one_words[''.join(order)] = []

    with file("simpsons.txt") as f:
        for line in f:
            m = regLine.match(line)
            if m is None:
                print line.rstrip()
                continue
            word = m.group('word')

            word = word.rstrip()
            if letter_count('o', word) == 1 and \
               letter_count('n', word) == 1 and \
               letter_count('e', word) == 1:
                order, pattern = one_order(word)
                patterns[pattern] += 1
                one_words[order].append(pattern)

    for pattern, count in patterns.items():
        if count > 1:
            print "%s is ambiguous (%d ways)" % (pattern, count)
            for order in permutations(['o', 'n', 'e']):
                try:
                    one_words[order].remove(pattern)
                except Exception:
                    pass

    for order in one_words:
        print "%d %s-words" % (len(one_words[order]), order)
        for pattern in one_words[order][:10]:
            if patterns[pattern] == 1:
                print pattern
        print


def one_order(word):
    """
    >>> one_order('phone')
    ('one', 'ph___')
    >>> one_order('phenom')
    ('eno', 'ph___m')
    >>> one_order('exoxn')
    ('eon', '_x_x_')
    """
    pattern = list(word)
    order = [word.find(ch) for ch in ('o', 'n', 'e')]
    order.sort()
    for i in order:
        pattern[i] = '_'
    return ''.join([word[i] for i in order]), ''.join(pattern)


def letter_count(letter, word):
    result = 0
    for c in word:
        if letter == c:
            result += 1
    return result

if __name__ == '__main__':
    main()
