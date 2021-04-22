<<<<<<< HEAD
# ctypes.sh

This is `ctypes.sh`, a foreign function interface for bash.

`ctypes.sh` is a bash plugin that provides a foreign function interface directly
in your shell. In other words, it allows you to call routines in shared
libraries from within bash.

A (very) simple example will help illustrate:

```bash
$ dlcall puts "hello, world"
hello, world

# A more complex example, use libm to calculate sin(PI/2)
$ dlopen libm.so.6
0x172ebf0
$ dlcall -r double sin double:1.57079632679489661923
double:1.000000
```

`ctypes.sh` can extend bash scripts to accomplish tasks that were previously
impossible, or would require external helpers to be written.

`ctypes.sh` makes it possible to use
[GTK+](https://github.com/taviso/ctypes.sh/blob/master/test/gtk.sh) natively in
your shell scripts, or write a [high-performance http daemon](https://github.com/cemeyer/httpd.sh).

See more examples [here](https://github.com/taviso/ctypes.sh/tree/master/test)

## prerequisites

`ctypes.sh` is dependent on the following libraries and programs:

* libffi
* bash
* libelf (optional)
* elfutils (optional)
* libdwarf / libdw (optional)


### Fedora

For recent Fedora, this should be enough:

`sudo yum install elfutils-devel dnf-utils`

Now you can use the `debuginfo-install` command to install debugging symbols for automatic structure support.

### Ubuntu

For recent Ubuntu, this should be enough:

`sudo apt install autoconf libltdl-dev libffi-dev libelf-dev elfutils libdw-dev`

If you want to use automatic struct support (recommended), you should also make
you have [ddebs available](https://wiki.ubuntu.com/Debug%20Symbol%20Packages).

## install

`ctypes.sh` can be installed from source like this:

```bash
$ git clone https://github.com/taviso/ctypes.sh.git
$ cd ctypes.sh
$ ./autogen.sh
$ ./configure
$ make
$ [sudo] make install
```

By default `ctypes.sh` is installed into `/usr/local/bin` and
`/usr/local/lib`. You can overload the prefix path by defining the
`PREFIX` environment variable before installing.

```bash
$ PREFIX=$HOME make install
```

## example

```bash
source ctypes.sh
puts () {
  dlcall puts "$@"
  return $?
}

puts "hello, world"
```

## Here is what people have been saying about ctypes.sh:

* "that's disgusting"
* "this has got to stop"
* "you've gone too far with this"
* "is this a joke?"
* "I never knew the c could stand for Cthulhu."

You can read more about ctypes.sh and see it in action on the [Wiki](https://github.com/taviso/ctypes.sh/wiki)
=======
# autogen.sh
<<<<<<< HEAD
autogen.sh is a POSIX shell script to manage GNU Autotools(autoconf automake) and other softwares used by your project.
>>>>>>> Initial commit
=======
`autogen.sh` is a `POSIX` shell script to manage `GNU` `Autotools`(`autoconf` `automake`) and other softwares used by your project.

## how to use
locate `autogen.sh` in your project.

## autogen.sh command usage
*   print the help infomation of `autogen.sh` command

        ./autogen.sh -h
        ./autogen.sh --help

*   print the version of `autogen.sh`

        ./autogen.sh -V
        ./autogen.sh --version

*   gen configure

        ./autogen.sh
        ./autogen.sh -x
        ./autogen.sh -d

## autogen.rc
`autogen.rc` is also a `POSIX` shell script. It is a extension of `autogen.sh`. It will be automatically loaded if it exists.

a typical example of this file looks like as follows:

```
required command cc
required command pkg-config ge 0.18
optional command python3    ge 3.5

gen_config_pre() {
    step "gen config pre"
    # do whatever you want."
}

gen_config() {
    step "gen config"
    run autoreconf -ivf
}

gen_config_post() {
    step "gen config post"
    # do whatever you want.
}
```

### the function can be declared in `autogen.rc`
|function|overview|
|-|-|
|`gen_config_pre(){}`|run before `gen_config(){}`|
|`gen_config(){}`|run command `autoreconf -ivf`|
|`gen_config_post(){}`|run after `gen_config(){}`|

### the function should be invoked on top of the `autogen.rc`
|function|overview|
|-|-|
|`required TYPE NAME [OP VERSION]`|declare required `command` / `perl` / `python` modules.|
|`optional TYPE NAME [OP VERSION]`|declare optional `command` / `perl` / `python` modules.|

### the function can be invoked in `autogen.rc`
|function|example|
|-|-|
|`print`|`print 'your message.'`|
|`echo`|`echo 'your message.'`|
|`info`|`info 'your infomation.'`|
|`warn`|`warn "warnning message."`|
|`error`|`error 'error message.'`|
|`die`|`die "please specify a package name."`|
|`success`|`success "build success."`|
|`sed_in_place`|`sed_in_place 's/-mandroid//g' Configure`|

### the variable can be used in `autogen.rc`
|variable|overview|
|-|-|
|`NATIVE_OS_TYPE`|current machine os type.|
|`NATIVE_OS_NAME`|current machine os name.|
|`NATIVE_OS_VERS`|current machine os version.|
|`NATIVE_OS_ARCH`|current machine os arch.|
|`PROJECT_DIR`|the project dir.|
|`PROJECT_NAME`|the project name.|
|`PROJECT_VERSION`|the project version.|
|`AUTOCONF_VERSION_MREQUIRED`|min required version of autoconf.|
>>>>>>> optimize
