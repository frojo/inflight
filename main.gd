extends Node2D

const SERVER_PORT := 27015
const MAX_CLIENTS := 16
const SERVER_IP = '127.0.0.1' # 'localhost'

enum NETWORK_STATE {
  None,
  Client,
  Server
}
var network_state = NETWORK_STATE.None

var peer
var debug_text = ''

# Called when the node enters the scene tree for the first time.
func _ready():
  get_tree().connect('network_peer_connected', self, '_peer_connected')
  get_tree().connect('connected_to_server', self, '_connected_ok')
  get_tree().connect('connection_failed', self, '_connected_fail')

  debug_print('waiting...')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass
   # if network_state == NETWORK_STATE.Client:
   #   $text.set_text('client | connection state = %s' % peer.get_connection_status())
   # elif network_state == NETWORK_STATE.Server:
   #   $text.set_text('server | connection state = %s' % peer.get_connection_status())
   # else: # network_state == NETWORK_STATE.None
   #   $text.set_text('waiting...')

func _input(event):
  if event is InputEventKey and event.pressed:
    if event.scancode == KEY_S && network_state == NETWORK_STATE.None:
      become_server()
    if event.scancode == KEY_C && network_state == NETWORK_STATE.None:
      become_client()

func become_client():
  network_state = NETWORK_STATE.Client

  debug_print('becoming a client...')

  # peer = NetworkedMultiplayerENet.new()
  peer = WebSocketClient.new()
  if not SERVER_IP.is_valid_ip_address():
    debug_print('%s is not valid ip address' % SERVER_IP)
  else:
    debug_print('%s IS a valid ip address' % SERVER_IP)
  # peer.create_client(SERVER_IP, SERVER_PORT)

  var url = "ws://localhost:" + str(SERVER_PORT)

  var error = peer.connect_to_url(url, PoolStringArray(), true);
  
  get_tree().set_network_peer(peer)

  var id = get_tree().get_network_unique_id()

  # $text.set_text('i am a client! network id: %s' % id)


func become_server():
  network_state = NETWORK_STATE.Server

  # peer = NetworkedMultiplayerENet.new()
  peer = WebSocketServer.new()
  # peer.create_server(SERVER_PORT, MAX_CLIENTS)
  peer.listen(SERVER_PORT, PoolStringArray(), true)
  get_tree().set_network_peer(peer)
  # peer.set_bind_ip(SERVER_IP)

  var id = get_tree().get_network_unique_id()

  debug_print('i am the server! network id: %s' % id)

func _peer_connected(id):
  debug_print('%s just connected!' % id)

func _connected_ok():
  debug_print('i connected to server!')

func _connected_fail():
  debug_print('my connection to server failed!')
  # $text.is_visible(false)

func debug_print(s):
  debug_text = debug_text + s + '\n'
  $text.set_text(debug_text)



