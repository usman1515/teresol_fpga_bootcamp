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
remove, and manage software packages on the system.

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
```

== Additional Examples
```bash
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
time, home directory, and other account information.
*Note:* The `finger` command is not installed by default on many modern Linux distributions and may
need to be installed separately.

== Examples

```bash
# Display information about the current user
finger
```

```bash
# Display information about a specific user
finger username
```

```bash
# Show logged-in users and their details
finger @localhost
```

```bash
# Install finger on Ubuntu
sudo apt install finger
```

// = `man`
//
// `man` (manual) displays the documentation pages for Linux commands. It is one of the most useful commands for learning how commands work, including available options and examples.
//
// == Examples
//
// ```bash
// # View the manual page for a command
// man ls
// ```
//
// ```bash
// # View documentation for the cp command
// man cp
// ```
//
// ```bash
// # Search manuals for a keyword
// man -k network
// ```
//
// ```bash
// # Open the manual for the man command itself
// man man
// ```
//
//
//
