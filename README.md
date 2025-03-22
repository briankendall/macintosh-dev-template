## Project Template for Retro68 and VSCode

This is a project template for classic Macintosh software development in modern macOS using Retro68 and Visual Studio Code. It includes special scripts that allows running your classic Mac application in Mini vMac with a simple command executed from Visual Studio Code, as well as instructions on how to set up a classic Mac to copy your application over a local network, so you can conveniently run it on real hardware. 

It also includes a simple logging library that allows getting console output from your app both when it's running from within Mini vMac _and_ when it's running on real hardware, if the classic Mac has MacTCP installed.

While this repo is set up specifically for VSCode, the scripts here could easily be adapted to other IDEs. It does make extensive use of both AppleScript and UNIX-like shells, though, so porting it to Linux or Windows would likely be tricky.


### Setup:


#### Requirements:

- Visual Studio Code
- Xcode
- MacPorts (or another package manager)
- Retro68 (and its requirements)
- Python 3
- flock

#### Optional prerequisites for running on real hardware:

- pure-ftpd
- hfsutils
- A classic Macintosh with the following installed: MacTCP, AppleScript, Anarchie FTP client, and optionally KeyQuencer.


#### Steps to build and run this project:

1. Make sure you have Visual Studio Code and Xcode installed

2. Follow the instructions to install Retro68 on their GitHub repo: [https://github.com/autc04/Retro68](https://github.com/autc04/Retro68)

3. Install flock. With MacPorts: `sudo port install flock`    
    (This is used to check and see if the disk images containing your classic mac app are still in use, to prevent overwriting it at very inopportune times.)

4. Install Python 3. It comes with Xcode, and that version will probably be fine. But you can also install a more up-to-date version using MacPorts or another package manager, e.g. `sudo port install python312`

5. Add the following environment variable that is set to the path to your Retro68 toolchain directory:
    
        RETRO68_TOOLCHAIN_PATH=~/path/to/retro68/Retro68-build/toolchain
    
6. Open Visual Studio Code, and install the "CMake Tools" extension if you haven't already done so.

7. Clone this repository to wherever you want to use it, and then in VSCode, pick the menu File > Open Folder and select the repository's folder

8. If you are prompted to pick a kit for the project, select Retro68, which should be one of the choices.

9. This project (in `./.vscode/tasks.json`) defines tasks for building and running the project. It's not strictly necessary to run the build task, but I set it up to better catch and display errors. For one, it will properly display multi-line errors. And perhaps more importantly, it will actually display link errors!    
    Try building the project. If all is well, it should build without errors!

10. Next, you need a window for displaying your application output. Open a terminal in either VSCode or your terminal app of choice, and then execute the following script located in the `./scripts` directory: `display-output.py`. This will display all output coming from Mini vMac, or your application running on an actual Mac!

11. Now try running the project by executing the "Run Application in Mini vMac" task. You can do this by pressing Command+Shift+P, typing in "Task: Run Task" and then selecting "Run Application in Mini vMac", or better yet, binding that task to a keystroke.    
    
    The first time you try to run the application, Mini vMac will launch automatically, but the app won't run. You need to grant Visual Studio Code two important permissions which macOS should prompt you for automatically: Accessibility and Automation permissions. Be sure to grant it those permissions when prompted.
    
    (If you unfortunately don't get these prompts, because macOS is awfully buggy when it comes to actually prompting for permissions, or because you accidentally _didn't_ grant the permission, then you'll need to go into System Settings / Privacy & Security, and then go into both the Accessibility section and Automation section, and in both cases find Visual Studio Code and grant it the permission. With Automation, you'll need to grant it permission to control System Events specifically.)
    
12. And with that out of the way... shut down Mini vMac by picking the menu Special > Shut Down in the emulated macOS environment.

13. Finally, try running your application again in VSCode.
    
    If all is working well, Mini vMac should launch automatically, a dialog box displaying "Hello world!" should appear in the emulated mac, and you should see `Hello world from the console!` appear in your terminal that's running `display-output.py`. As soon as you click OK in the dialog box and the application quits, Mini vMac should become hidden automatically.
    
Now you're ready to do some classic Mac OS development! Feel free to change the application as you desire. You have a handy emulated environment for testing it out, complete with console output!




### Running on a classic Mac:

If you want to be able to conveniently copy and run your application on a classic Mac with just a single keystroke or running a single app, there's some setup involved on both your development mac and your classic mac.

##### Setup on dev mac:

First, on your modern development mac, you need to set up an FTP server. I did this using pure-ftpd, though in theory any FTP server that's compatible with a really, really old FTP client will work.

Here are some instructions for setting that up. Note that you can change the paths of things to your liking:

1. Install pure-ftp: `sudo port install pure-ftpd`
2. Create a directory that'll be hosted on the server: `mkdir -p ~/ftp/macintosh`
3. Create an FTP user: `sudo pure-pw useradd macintosh -u 501 -g 501 -d ~/ftp/macintosh`    
    This will prompt you for a password for this account. I used `macintosh`. Note: don't confuse the prompt for the FTP password with the password prompt for `sudo`!
4. Run: `sudo pure-pw mkdb`
5. Set up pure-ftpd to be able to start up automatically:

        sudo cp /opt/local/share/doc/pure-ftpd/org.pure-ftpd.ftpd.plist.basic.sample \
          /Library/LaunchDaemons/org.pure-ftpd.ftpd.plist`
6. Start it running: `sudo launchctl load -w /Library/LaunchDaemons/org.pure-ftpd.ftpd.plist`
7. If you're running macOS 13 or later, note that the first time you try to connect to the FTP server, macOS may ask you if you want to allow it to accept incoming connections. Be sure to grant it that permission!

Now, define the following environment variables:

    export MACINTOSH_FTP_STAGING_PATH=~/ftp/macintosh
    export MACINTOSH_LOGGING_LOCAL_IP=###.###.###.###

For `MACINTOSH_LOGGING_LOCAL_IP`, set it to the local IP address of your mac. This is where your classic mac will send its console output to. You could use a different IP if you wanted to for some reason.

If you want to get clever about it, you could define the variable as:

    export MACINTOSH_LOGGING_LOCAL_IP=$(ipconfig getifaddr en0)
    
replacing en0 with whichever network adapter you're using. (Typically it'll be en0 or en1 depending on whether you're connected using Wi-Fi or Ethernet.)

With those both set up, restart VSCode if it's running. Now when you build your project in VSCode, two things will happen:

1. The build process will automatically copy a MacBinary encoded version of your app into the FTP directory

2. The logging library will try to send its console output to your mac's IP address when it detects its running on real hardware

`display-output.py` will automatically listen for console output being sent from the real mac and display it. This gives you a handy, single terminal window to get output both from running your app in Mini vMac as well as on an actual Macintosh.

##### Setup on your classic mac:

In order to get your classic mac to automatically grab the latest version of your app and run it, you'll need to install the following:

- MacTCP
- Anarchie (an FTP client)
- AppleScript (for automating everything)
- KeyQuencer (for binding it to a keyboard shortcut)

This has all been tested in System 7.1. In theory it could work in System 6 and System 7.5, though the automation with AppleScript won't be available in System 6.

If you're using OpenTransport then the logging won't work, since its implemented using MacTCP. It could however be modified to detect and make use of OpenTransport. (Perhaps a future improvement!)

First, install Anarchie. (It's available on Macintosh Garden and elsewhere.) Once installed, open its Preferences, and check the box for "Decode Files".

Next, use Script Editor to create an AppleScript with something like the following:

    tell application "Anarchie"
       fetch alias "Macintosh HD:Staging:" url "ftp://macintosh:macintosh@###.###.###.###/MyApplication"
    end tell
    
The `alias` argument is the path where it will put the file, and you can have it put it wherever you want. Obviously replace ###.###.###.### with the local IP address of your dev mac, replace the app name with the actual name of your app, and make sure the path on the FTP server to where VSCode is copying your application is correct. That should connect to the FTP server, fetch the file, and automatically decode it, so your app is ready to run once it's done!

Save it as an application rather than just a script file so that you can just launch it to run it. (Be sure to check "Never Show Startup Screen" since otherwise you'll be nagged by it every time.) I put it on my desktop so that it's conveniently right there, ready to open, but again you can put it anywhere you want.

At this point, you could also modify the AppleScript to automatically launch your app. But I opted to use KeyQuencer (also available on Macintosh Garden) both so that I could bind it all to a keyboard shortcut, and so that the AppleScript will be finished running and have freed its resources by the time the app launches. (AppleScripts are a bit heavy weight. KeyQuencer has the advantage of being quite light weight.)

Once it's installed, I opened its control panel and created a macro with the following script:

    Open application "Macintosh HD:Desktop Folder:Copy MyApplication"
    WaitApp "Copy MyApplication" closed
    Wait 30 ticks
    Open application "Macintosh HD:Staging:MyApplication"

and then assigned it to a keystroke. Now all I have to do is type that keystroke on my classic Mac and it will automatically fetch and run my application, sending all console output to my dev mac! Replace the paths and app name in this script with your own, and it should work for you too.

#### How it all works

All of the source code is available in this repo, but there's a few hacky things going on to make this all possible.

First, I've modified the source code to Mini vMac in a number of ways. The major change is usurping its function where you can use clipboard sharing in order to pass text back and forth between the host and guest OS. I've set it up so that if text strings with certain prefixes are sent to Mini vMac's clipboard exporting feature, then rather than processing them normally, it will do one of several things:

1. `MSG:boot` is triggered on boot, and turns off "run in background" and set the emulated mac's speed to not be "all out". The included disk image in the repo is set up so that, on startup, it will run an app that triggers this message. This way the emulated mac can boot up as quickly as possible but then reset to a sensible speed once it's up and running.

2. For `MSG:start`, which is triggered right before the app launches, it'll turn on "run in background" so that the app keeps running regardless of which app has focus

3. For `MSG:quit`, which is triggered after the app quits, it turns back off "run in background".

4. Finally, `OUT:...'` will print whatever comes after the `OUT:` to stdout. Thus we have a way of getting at console output in the host OS.

If you want to see all of my changes, look for `Bri change!` in the included Mini vMac source code.

The logging library makes use of the same code that Mini vMac's "ClipOut" app uses to trigger these messages. Because that code was intended to be compiled with a classic Mac compiler and not Retro68, I used Think C to compile it and then converted the static library it produced into a static library that can be used by gcc. I also created a KeyQuencer extension called "ClipOut" that allows triggering these messages from a KeyQuencer macro. (Source code and Think C project files for both the ClipOut library and the KeyQuencer extension are included in .sit files in the repo.)

The disk image in the repo has everything necessary installed and set up so that all of these things will happen when executing the VSCode task for running the application. That task does a few things too to try and create a pleasing development experience, where running the app mirrors the behavior of running a native app: it shows (or if necessary launches) Mini vMac when the app is launched, hides Mini vMac when the app quits. The app is launched in the emulated mac by automating a keystroke that KeyQuencer is set up to intercept. This is all done mainly through AppleScript. To learn about it in more detail, it's all there in the various scripts, especially `run-app-in-minivmac.sh`.

Lastly, the repo includes a pre-built version of Mini vMac with all of these modifications in place. It's an x86_64 build, so if you're on Apple Silicon and want a native experience (not that it's really necessary, since it runs great in Rosetta 2), the included `build.sh` script in the `minivmac` subdirectory should rebuild Mini vMac with everything configured correctly.

##### Other operating systems

In theory this same approach could be used to do classic Mac development in Linux without too much modification. The only part that would take more significant work would be replacing AppleScript with something similar, since it's used to show and hide windows, and simulate a keystroke. In Windows, there'd need to be either a compatible bash-like environment that can run these various scripts and handle named pipes, or they'd need to be replaced with something else.

--

 This was made as part of Marchintosh 2025! 
