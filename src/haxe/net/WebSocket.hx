package haxe.net;

// Available in all targets including javascript
import haxe.io.Bytes;

enum ReadyState {
	Connecting;
	Open;
	Closing;
	Closed;
}

/**
 * High-level WebSocket.
 * Underlying implementation is WebSocketGeneric for non-js and non-flash
 * platform.
 *
 * According to RFC6455, frames should be masked if and only if they are issued from a client to a server.
 * Thus this is set to false in create() default implementation (it's a dynamic
 * function so pay attention if you redefine it) and to true in 
 * createFromAcceptedSocket(). Those are the two public function and ctor is
 * private, so it should do.
 */ 
class WebSocket {
    private function new() {
    }

    /**
     * Create a client socket.
     * It is similar but will have masking frames enabled.
     */
    dynamic static public function createClient(
            url       : String,
            protocols : Array<String> = null,
            origin    : String        = null,
            debug     : Bool          = false
    ) : WebSocket {
        #if js
            return new haxe.net.impl.WebSocketJs(url, protocols);
        #elseif flash
            if (haxe.net.impl.WebSocketFlashExternalInterface.available()) {
                return new haxe.net.impl.WebSocketFlashExternalInterface(url, protocols);
            }
        #else
            var wsg = haxe.net.impl.WebSocketGeneric.create(url, protocols, origin, "wskey", debug);
            // here is the difference:
            wsg.setMasking(true);
            return wsg;
        #end
    }

    /**
     * Create a socket.
     * Those sockets are created by default with setMasking(true)
     * (frames sent in direction client->server are to be masked, and we have
     * createFromAcceptedSocket() below which setMasking(false)).
     */
    dynamic static public function create(
            url       : String,
            protocols : Array<String> = null,
            origin    : String        = null,
            debug     : Bool          = false
    ) : WebSocket {
        #if js
            return new haxe.net.impl.WebSocketJs(url, protocols);
        #elseif flash
            if (haxe.net.impl.WebSocketFlashExternalInterface.available()) {
                return new haxe.net.impl.WebSocketFlashExternalInterface(url, protocols);
            }
        #else
            return haxe.net.impl.WebSocketGeneric.create(url, protocols, origin, "wskey", debug);
        #end
    }
	
	#if sys
	/**
	 * create server websocket from socket returned by accept()
	 * wait for onopen() to be called before using websocket.
     * Since this is very likely to be a socket owned by a "server", it will
     * setMasking(false) (frames sent in direction server->client are not masked).
	 * @param	socket - accepted socket 
	 * @param	alredyRecieved - data already read from socket, it should be no more then full http header
	 * @param	debug - debug messages?
	 */
    static public function createFromAcceptedSocket(
            socket          : Socket2,
            alreadyReceived : String = '',
            debug           : Bool   = false
    ) : WebSocket {
		return haxe.net.impl.WebSocketGeneric.createFromAcceptedSocket(socket, alreadyReceived, debug);
	}
	#end

    static dynamic public function defer(callback: Void -> Void) {
        #if (flash || js)
        haxe.Timer.delay(callback, 0);
        #else
        callback();
        #end
    }

    public function process() {
    }

    public function sendString(message:String) {
    }

    public function sendBytes(message:Bytes) {
    }
	
	public function close() {
	}
	
	public var readyState(get, never):ReadyState;
	function get_readyState():ReadyState throw 'Not implemented';

    public dynamic function onopen():Void {
    }

    public dynamic function onerror(message:String):Void {
    }

    public dynamic function onmessageString(message:String):Void {
    }

    public dynamic function onmessageBytes(message:Bytes):Void {
    }

    public dynamic function onclose():Void {
    }
}
