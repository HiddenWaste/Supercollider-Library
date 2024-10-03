s.boot;



//FIRST OSC COMMAND!

s.sendMsg('/s_new', 'default', 2456, 0, 1);

s.sendMsg('/n_free', 3456);

s.sendMsg('/n_set', 3456, 'freq', 78, 'amp', 1.2);
s.sendMsg('/n_set', 2456, 'freq', 250, 'amp', 0.4);

//Supercollider to itself
~carter = NetAddr.new("192.168.56.1", 57120);

NetAddr.langPort;



b = NetAddr.new("127.0.0.1", 7771);

b.sendMsg("/hello", "there");

NetAddr.langPort;    // Retrieve the current port SC is listening to
//  default SC port is 57120

NetAddr.localAddr    // retrieve the current IP and port

thisProcess.openPorts; // list all open ports




// To listen to incoming messages, an OSCFunc needs to be created
//    if the sending application has a fixed port it sends form
//         we can set the OSC function to only listen to that IP and port

n = NetAddr.new("127.0.0.1", 57120)

o = OSCFunc({
	arg msg, time, addr, recvPort;
	[msg, time, addr, recvPort].postln; },
path: n);

o.free; // Remove OSCFunc when done


// Lets listen for all incoming OSC Messages!
OSCFunc.trace(true);     // Turn Posting On
OSCFunc.trace(false);    // Turn Posting Off




