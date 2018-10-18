# SystemProcess
Spawing \*NIX system process using posix_spawn

# Usage Example

Execute a command and redirect its stdout

```Smalltalk
|o|
o:= SystemProcess new.
o redirectStdout.
o onOutputDo: [
	:d| Transcript show: d
].
o onFinishDo: [ o cleanup ].
o shellCommand: { 'ls'. '-al' }.
```

Execute a command and redirect its stdin, stdout:

```Smalltalk
|o crlf|
crlf := Character cr asString, Character lf asString.
o:= SystemProcess new.
o redirectStdout.
o redirectStdin.
o onOutputDo: [
	:d| Transcript show: d
].
o onFinishDo: [ o cleanup ].
o shellCommand: { '/bin/sh'}.
o stdinStream nextPutAll: 'ls -al', crlf.
"exit /bin/sh"
o stdinStream nextPutAll: 'exit',crlf
```
