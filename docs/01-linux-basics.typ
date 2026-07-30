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

= `mkdir`
Creates one or more new directories (folders). It is commonly used to organize files and projects.

== Examples
```bash
# Create a new directory
mkdir projects

# Create multiple directories
mkdir docs scripts logs

# Create nested directories
mkdir -p ./directory_1/directory_2/directory_3

# Create a directory in another location
mkdir ~/Downloads/temp
```

= `cp`
Copies files and directories from one location to another.

== Examples
```bash
# Copy a file
cp report.txt backup.txt

# Copy a file to another directory
cp report.txt ~/Documents/

# Copy an entire directory
cp -rv project backup_project

# Copy multiple files
cp file1.txt file2.txt ~/Documents/
```

= `rm`
Removes (deletes) files and directories. Use with caution, as deleted files are generally not moved
to a recycle bin.

== Examples
```bash
# Delete a file
rm notes.txt

# Delete multiple files
rm file1.txt file2.txt

# Delete an empty directory tree
rm -r old_project

# Forcefully delete a directory and everything inside without asking
rm -rf old_project

# Ask for confirmation before deleting
rm -i important.txt
```

= `rmdir`
Removes empty directories. It only works if the directory contains no files or subdirectories.

== Examples
```bash
# Remove an empty directory
rmdir temp

# Remove multiple empty directories
rmdir logs cache output

# Remove nested empty directories
rmdir -p projects/fpga/tutorials

# Remove an empty directory in another location
rmdir ~/Downloads/temp
```

= `ln`
Creates links between files. A hard link points directly to the file data, while a symbolic (soft)
link acts like a shortcut.

== Examples
```bash
# Create a symbolic link
ln -s report.txt latest_report.txt

# Create a symbolic link to a directory
ln -s ~/Documents docs

# Create a hard link
ln report.txt report_backup.txt
```

= `clear`
Clears the terminal screen, making it easier to work without previous output cluttering the display.

== Examples
```bash
# Clear the terminal
clear

# Run several commands, then clear the screen
ls
pwd
clear

# Clear after editing a file
nano notes.txt
clear
```

= `whoami`
Displays the username of the currently logged-in user.

== Examples
```bash
# Show the current username
whoami

# Check your user before running commands
whoami
pwd

# Use in a shell script
echo "Current user: $(whoami)"
```

= `sudo`
Runs a command with administrator (root) privileges. Only authorized users can use `sudo`.

== Examples
```bash
# Update package information
sudo dnf update

# Install a package
sudo dnf install git

# Edit a system configuration file
sudo nano /etc/hosts

# Restart the system
sudo reboot
```

= `exit`
Ends the current shell session or exits a terminal program.

== Examples
```bash
# Exit the current terminal session
exit

# Exit after using su
su alice
exit

# Exit a remote SSH session
exit

# Exit a Bash shell started manually
bash
exit
```

= `passwd`
Changes the password of a user account. A normal user can change their own password, while
administrators can change passwords for other users.

== Examples
```bash
# Change your own password
passwd

# Change another user's password
sudo passwd alice

# Force a user to change their password at next login
sudo passwd --expire alice

# Lock a user account
sudo passwd -l alice
```

= `apt`
`apt` (Advanced Package Tool) is a package management command used on Debian-based Linux
distributions such as Ubuntu. It allows users to install, update, remove, and manage software
packages from software repositories.

== Examples
```bash
# Update the list of available packages
sudo apt update

# Upgrade installed packages to the latest versions
sudo apt upgrade

# Install a software package
sudo apt install git

# Remove an installed package
sudo apt remove git
```

= `dnf`
`dnf` (Dandified YUM) is a package management command used in Fedora, Red Hat Enterprise Linux
(RHEL), CentOS Stream, and other Red Hat-based Linux distributions. It is used to install, update,
remove, and manage software packages on the system. \
`dnf` is the modern replacement for `yum` and provides improved dependency handling and performance.

== Examples
```bash
# Update all installed packages
sudo dnf update

# Install a software package
sudo dnf install git

# Remove an installed package
sudo dnf remove git

# Search for available packages
dnf search python

# Display information about an installed package
dnf info git

# List installed packages
dnf list installed

# Clean cached package data
sudo dnf clean all

# Show available package updates
dnf check-update
```

= `finger`
Displays information about users on a Linux system. It can show details such as username, login
time, home directory, and other account information. \
*Note:* The `finger` command is not installed by default on many modern Linux distributions and may
need to be installed separately.

== Examples

```bash
# Display information about the current user
finger

# Display information about a specific user
finger username

# Show logged-in users and their details
finger @localhost

# Install finger on Ubuntu
sudo apt install finger
```

= `man`
`man` (manual) displays the documentation pages for Linux commands. It is one of the most useful
commands for learning how commands work, including available options and examples.

== Examples
```bash
# View the manual page for a command
man ls

# View documentation for the cp command
man cp

# Search manuals for a keyword
man -k network

# Open the manual for the man command itself
man man
```

= `whatis`
Provides a short description of a Linux command. It searches the manual page database and displays a
brief explanation of what a command does. \
It is useful when you remember a command name but need a quick reminder of its purpose.

== Examples
```bash
# Get a short description of a command
whatis ls

# Find information about the cp command
whatis cp

# Check multiple commands
whatis grep find mkdir

# Get a description of the man command
whatis man
```

= `curl`
Client URL (`curl`) is a command-line tool used to transfer data between a computer and a server. It
is commonly used for downloading files, testing APIs, and communicating with web services.

== Examples
```bash
# Download a file from a URL
curl -O https://example.com/file.html

# Display the contents of a webpage
curl https://example.com

# Check the response headers from a website
curl -I https://example.com
curl -I https://duckduckgo.com/
```

= `zip`
Creates compressed archive files. It is used to reduce file size and package multiple files together
for easier storage or sharing.

== Examples
```bash
# Compress a single file
zip archive.zip file.txt

# Compress multiple files
zip project.zip file1.txt file2.txt

# Compress an entire directory
zip -r project.zip project/

# View files inside a zip archive
zipinfo project.zip
```

= `unzip`
Extracts files from a ZIP archive. It is used to restore compressed files back to their original
form.

== Examples
```bash
# Extract a zip file
unzip archive.zip

# Extract into a specific directory
unzip archive.zip -d ~/Documents/

# List files inside a zip archive
unzip -l archive.zip

# Extract and overwrite existing files
unzip -o archive.zip
```

= `less`
Displays the contents of a file one page at a time. It is useful for reading large files because it
does not load the entire file into the terminal at once.

== Examples
```bash
# Open a text file
less notes.txt

# View a log file
less system.log

# View command output page by page
dmesg | less

# Search inside a file
less /var/log/syslog
```
- Useful navigation keys inside `less`:
```bash
Space  - Move forward one page
b      - Move backward one page
/word  - Search for text
q      - Quit
```

= `head`
Displays the first few lines of a file. It is commonly used to quickly inspect the beginning of
files or logs.

== Examples
```bash
# Display the first 10 lines of a file
head file.txt

# Display the first 20 lines
head -n 20 file.txt

# View the beginning of a log file
head /var/log/syslog

# Display the first lines of command output
ls -l | head
```

= `tail`
Displays the last few lines of a file. It is commonly used for checking the latest entries in log
files.

== Examples
```bash
# Display the last 10 lines of a file
tail file.txt

# Display the last 20 lines
tail -n 20 file.txt

# Monitor a log file in real time
tail -f /var/log/syslog

# View the latest command output
dmesg | tail
```

= `cmp`
Compares two files byte by byte and reports whether they are identical or where the first difference
occurs. It is useful for checking whether two files are exactly the same.

== Examples
```bash
# Compare two files
cmp file1.txt file2.txt

# Compare two binary files
cmp program1.bin program2.bin

# Compare files and show differences
cmp -l file1.txt file2.txt

# Compare generated output files
cmp output_old.txt output_new.txt
```

