OPTIONS = ["data-start-line-number", 
           "data-font-size", 
           "data-min-lines",
           "data-max-lines",
           "data-dark-theme-mode",
           "data-button-name",
           "data-readonly",
           "data-hidden",
           "data-stdin-taid",
           "data-file-taids",
           "data-file-upload-id",
           "data-params",
           "data-code-mapper",
           "data-prefix",
           "data-suffix",
           "data-html-output",
           "data-max-output-length",
           "line-numbers"]

DISPLAY_G1_OPTIONS = [
    "data-start-line-number", 
    "data-min-lines",
    "data-max-lines",
    "line-numbers",
]

DISPLAY_G2_OPTIONS = [
    "data-font-size", 
    "data-dark-theme-mode",
    "data-hidden",
    "data-button-name",
]

DATA_G1_OPTIONS = [
    "data-stdin-taid",
    "data-file-taids",
    "data-file-upload-id",
]

DATA_G2_OPTIONS = [
    "data-readonly",
    "data-params",
    "data-html-output",
    "data-max-output-length",
]

DATA_G3_OPTIONS = [
    "data-code-mapper",
    "data-prefix",
    "data-suffix",
]

OVERALL = [
    "data-start-line-number, data-min-lines, data-max-lines",
    "data-font-size, data-dark-theme-mode, data-button-name",
    "data-hidden",
    "data-readonly, data-params, data-html-output, data-max-output-length",
    "data-code-mapper, data-prefix, data-suffix",
]


def permutate(options: list[str], max_depth: int) -> list[str]:
    cross: list[str] = options[:]
    master: list[str] = cross[:]
    for _ in range(max_depth):
        new_cross: list[str] = []
        for opt in options:
            for combination in cross:
                invalid_pairing = (
                    ("line" in opt and "hidden" in combination) or 
                    ("hidden" in opt and "line" in combination) or 
                    ("stdin" in opt and "file" in combination) or
                    ("file" in opt and "stdin" in combination) or
                    ("line-numbers" in opt and "data-start-line-number" in combination) or
                    ("data-start-line-number" in opt and "line-numbers" in combination) or
                    (opt in combination)
                )
                if not invalid_pairing:
                    new_cross.append(f"{combination}, {opt}") 
        cross = new_cross[:]
        master.extend(cross)

    a = [set([x.strip() for x in elem.split(',')]) for elem in master]
    b: list[set[str]] = []
    for candidate in a:
        if candidate not in b and len(candidate) > 1:
            b.append(candidate)
    master = []
    for item in b:
        master.append(', '.join(item))

    return master

master: list[str] = []
master.extend(OPTIONS)

display_g1_options = permutate(DISPLAY_G1_OPTIONS, len(DISPLAY_G1_OPTIONS))
master.extend(display_g1_options)

display_g2_options = permutate(DISPLAY_G2_OPTIONS, len(DISPLAY_G2_OPTIONS))
master.extend(display_g2_options)

data_g1_options = permutate(DATA_G1_OPTIONS, len(DATA_G1_OPTIONS))
master.extend(data_g1_options)

data_g2_options = permutate(DATA_G2_OPTIONS, len(DATA_G2_OPTIONS))
master.extend(data_g2_options)

data_g3_options = permutate(DATA_G3_OPTIONS, len(DATA_G3_OPTIONS))
master.extend(data_g3_options)

overall = OVERALL[:]
overall.extend(data_g1_options)
overall_options = permutate(overall, len(overall))
master.extend(overall_options)

#master = set(master)
print(len(master))
for combination in master:
    print(combination)
