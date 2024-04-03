from Bio import SeqIO
import sys
import argparse

def getKeys(args):
    """Turns the input key file into a list. May be memory intensive."""
    keys = []
    try:
        with open(args.keys, "r") as kfh:
            for line in kfh:
                line = line.rstrip('\n')
                keys.append(line)
    except FileNotFoundError:
        # If the file is not found, treat args.keys as a single string
        keys.append(args.keys)
    return keys

def main():
    """Takes a string or list of strings in a text file (one per line) and retrieves them and their sequences from a provided multifasta."""
    try:
        parser = argparse.ArgumentParser(description='Retrieve one or more fastas from a given multifasta.')
        parser.add_argument(
            '-f',
            '--fasta',
            action='store',
            required=True,
            help='The multifasta to search.')
        parser.add_argument(
            '-k',
            '--keys',
            action='store',
            required=True,
            help='A string provided directly, or a file of header strings to search the multifasta for. Must contain a common segment shared with headers in the multifasta.')
        parser.add_argument(
            '-o',
            '--outfile',
            action='store',
            default=None,
            help='Output file to store the new fasta sequences in. Just prints to screen by default.')
        parser.add_argument(
            '-v',
            '--verbose',
            action='store_true',
            help='Set whether to print the key list out before the fasta sequences. Useful for debugging.')
        parser.add_argument(
            '-i',
            '--invert',
            action='store_true',
            help='Invert the search, and retrieve all sequences NOT specified in the keyfile.')
        args = parser.parse_args()

    except argparse.ArgumentError:
        print('An exception occurred with argument parsing. Check your provided options.')
        sys.exit(1)

    keys = []
    try:
        keys = getKeys(args)
    except IOError:
        keys.append(args.keys)
    else:
        print("Couldn't determine keys from your provided file or string. Double check your file, or ensure your string is quoted correctly.")

    if args.verbose:
        if args.invert is False:
            print('Fetching the following keys from: ' + args.fasta)
            for key in keys:
                print(key)
        else:
            print('Ignoring the following keys, and retrieving everything else from: ' + args.fasta)
            for key in keys:
                print(key)

    seqIter = SeqIO.parse(args.fasta, 'fasta')

    if args.outfile:
        with open(args.outfile, "w") as outFile:
            for seq in seqIter:
                if args.invert is False:
                    for key in keys:
                        if key in seq.id:
                            print(seq.format("fasta"), file=outFile)
                            break  # Break after first match if not in invert mode
                else:
                    found = False
                    for key in keys:
                        if key in seq.id:
                            found = True
                            break
                    if not found:
                        print(seq.format("fasta"), file=outFile)
    else:
        for seq in seqIter:
            if args.invert is False:
                for key in keys:
                    if key in seq.id:
                        print(seq.format("fasta"))
                        break  # Break after first match if not in invert mode
            else:
                found = False
                for key in keys:
                    if key in seq.id:
                        found = True
                        break
                if not found:
                    print(seq.format("fasta"))

if __name__ == "__main__":
    main()
