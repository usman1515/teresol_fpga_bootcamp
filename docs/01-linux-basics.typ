#set page(
  paper: "a4",
  margin: 1in,
)

// number all headings
#set heading(numbering: "1.1.")

// TODO: update font to something different
// #set text(font: "Libertinus Serif")

#align(center)[

  #v(2.8cm)
  #text(size: 34pt, weight: "bold")[
    Linux Fundamentals
  ]

  #text(size: 20pt, fill: rgb("#666666"))[
    for FPGA Development
  ]
  #v(1cm)

  #line(length: 55%)

  #v(2.2cm)
  #text(size: 14pt)[
    Onboarding Tutorial
  ]

  #v(1.8cm)
  #table(
    columns: (1fr, 2fr),
    stroke: none,
    inset: 6pt,

    [*Prepared by*], [Usman Siddique],
    [*Organization*], [TeReSol Pvt. Ltd.],
    [*Department*], [FPGA Hardware Engineering Team],
    [*Document Version*], [1.0],
    [*Last Updated*], [#datetime.today().display()],
  )

  #v(3cm)
  // #text(size: 10pt, fill: gray)[
  //   Confidential • Internal Engineering Documentation
  // ]
]

// Table of Contents
#pagebreak()
#outline()
#pagebreak()

= `ls`
Displays the contents of a directory, allowing you to see files and folders. It is one of the most
commonly used commands for navigating the Linux filesystem.

== Examples
```bash
# List files in the current directory
ls

# Show detailed information
ls -l

# Show hidden files as well
ls -a

# List files in another directory
ls /home/user/Documents
```

= `pwd`
Prints the full path of your current working directory. This is useful for knowing exactly where you
are in the filesystem.

== Examples
```bash
# Display the current directory
pwd

# Navigate somewhere and verify your location
cd ~/Documents
pwd

# Move to the root directory and check
cd /
pwd

# Move to your home directory and verify
cd ~
pwd
```

= `cd`
Changes your current working directory. It is the primary command used to navigate the Linux
filesystem.

== Examples
```bash
# Move into a directory
cd Documents

# Go back one directory
cd ..

# Return to your home directory
cd ~

# Go directly to the root directory
cd /
```

= `touch`
Creates a new empty file or updates the modification timestamp of an existing file.

== Examples
```bash
# Create an empty file
touch notes.txt

# Create multiple files at once
touch file1.txt file2.txt file3.txt
touch notes.txt README.md mux_2x1.sv

# Create a Verilog source file
touch counter.v

# Update the timestamp of an existing file
touch notes.txt
```

= `echo`
Prints text to the terminal or writes text to a file. It is commonly used in shell scripts and for
creating simple text files.

== Examples
```bash
# Print a message
echo "Hello, World!"

# Display the current username
echo $USER

# Display the current hostname
echo $HOSTNAME

# Save text to a file
echo "Hello Linux" > hello.txt

# Append text to an existing file
echo "Another line" >> hello.txt
```

= `cat`
Displays the contents of a file or combines multiple files together. It is commonly used to quickly
view text files without opening them suing a text editor.

== Examples
```bash
# Display a file
cat notes.txt

# Display multiple files
cat file1.txt file2.txt

# Create a new file from terminal input
cat > notes.txt

# Combine two files into one
cat file1.txt file2.txt > combined.txt
```

= `shred`
Securely overwrites a file multiple times before deleting it, making data recovery much more
difficult. It is useful when permanently removing sensitive files.

== Examples
```bash
# Securely overwrite a file
shred secrets.txt

# Overwrite and remove the file
shred -u secrets.txt

# Perform multiple overwrite passes
shred -n 5 secrets.txt

# Securely erase a temporary file
shred -u temporary.log
```

== Tutorial: Securely Deleting a File with `shred`
This example demonstrates how to create a text file, write some data into it, view its contents, and
then securely erase the data using the `shred` command.

- *Step 1:* Create a text file
  ```bash
  touch hello.txt
  ```
- *Step 2:* Write text into the file
  ```bash
  echo "Hello, World!" > hello.txt
  ```
- *Step 3:* Verify the contents
  ```bash
  cat hello.txt
  ```
- *Step 4:* Securely overwrite the file
  ```bash
  shred hello.txt
  ```
- *Step 5:* View the file again
  ```bash
  cat hello.txt
  ```
- *Step 6 (Optional):* Securely overwrite and delete the file
  ```bash
  shred -u hello.txt
  ```
  The `-u` option removes the file after overwriting it.
  ```bash
  ls
  ```
