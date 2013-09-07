#include <Firmata.h>
#include <RCSwitch.h>
#include <IRremote.h>

// Firmata Commands
enum Messages {
  RECV_RC_ON   = 0x20,
  RECV_RC_OFF  = 0x21,
  SEND_RC      = 0x35,
  SEND_IR      = 0x36,
  SEND_DOOR    = 0x37,
};

// Used Pins
enum Pins {
  PIN_IR       = 11,
  PIN_RC_SEND  = 8,
  PIN_RC_RECV  = 0, // Receiver on interrupt 0 => that is pin #2
  PIN_DOOR     = 9
};

// Door States
enum DoorStates {
  DOOR_OPEN    = HIGH,
  DOOR_CLOSED  = LOW
};

// Global constants
IRrecv irrecv(PIN_IR);
RCSwitch rcSwitchControl = RCSwitch();
int lastDoorState = DOOR_CLOSED;

/* Extracts the switch portion of the rcAddres.
 */
static byte getSwitch(char* rcAddress) {
  // Parse the switch number and if it should be turned on
  return (rcAddress[5] - 'A') + 1;
}

/* Turns the switch on.
 * @param rcAddress The data used to switch are in this format
 *                  "11110A". The first five chars are the group
 *                  of the switch the next is the switch char.
 */
void rcSwitchOn(char* rcAddress) {
  byte switchNr = getSwitch(rcAddress);
  rcAddress[5] = '\0'; // remove everything but the bit pattern
  rcSwitchControl.switchOn(rcAddress, switchNr);
}

/* Turns the switch off.
 * @param rcAddress The data used to switch are in this format
 *                  "11110A". The first five chars are the group
 *                  of the switch the next is the switch char.
 */
void rcSwitchOff(char* rcAddress) {
  byte switchNr = getSwitch(rcAddress);
  rcAddress[5] = '\0'; // remove everything but the bit pattern
  rcSwitchControl.switchOff(rcAddress, switchNr);
}

void stringDataProxy(char* data) {
  switch((byte)data[0]) {
    case RECV_RC_ON:
      rcSwitchOn(&data[1]);
      break;
    case RECV_RC_OFF:
      rcSwitchOff(&data[1]);
      break;
    default:
      // TODO error handling
      break;
  }
}

void setup()
{
  rcSwitchControl.enableTransmit(PIN_RC_SEND);
  rcSwitchControl.enableReceive(PIN_RC_RECV);
  irrecv.enableIRIn();

  pinMode(PIN_DOOR, INPUT);

  Firmata.setFirmwareNameAndVersion("Home Control", 1, 1);
  Firmata.attach(STRING_DATA, stringDataProxy);
  Firmata.begin();
}

void rcReceiveAndTransmit() {
  if (rcSwitchControl.available()) {
    long decimal = rcSwitchControl.getReceivedValue();

    if (decimal == 0) {
      Firmata.sendString(SEND_RC, "Error: Unknown encoding");
    } else {
      char instructionBuffer[70];
      String instruction = String(decimal); // 21780
      String sep = String('|');
      instruction += sep;
      instruction += String(rcSwitchControl.getReceivedBitlength()); // 24 bit
      instruction += sep;
      instruction += String(rcSwitchControl.getReceivedDelay()); // 322 (ms)
      instruction += sep;
      instruction += String(rcSwitchControl.getReceivedProtocol()); // 1
      instruction.toCharArray(instructionBuffer, sizeof(instructionBuffer));
      Firmata.sendSysex(SEND_RC, (byte)instruction.length(),
                                 (byte *)instructionBuffer);
    }

    rcSwitchControl.resetAvailable();
  }
}

void irReceiveAndTransmit() {
  decode_results results;

  if (irrecv.decode(&results)) {
    String ircode = String(results.value);
    char ircodeBuffer[20];
    ircode.toCharArray(ircodeBuffer, sizeof(ircodeBuffer));
    Firmata.sendSysex(SEND_IR, (byte)ircode.length(),
                               (byte *)ircodeBuffer);
    irrecv.resume();
  }
}

void processDoorAndTransmit() {
  int newDoorState = digitalRead(PIN_DOOR);

  if (newDoorState != lastDoorState) {
    // state of the door changed
    Firmata.sendString(SEND_DOOR,
      (newDoorState == DOOR_OPEN ? "OPEN" : "CLOSE"));
    lastDoorState = newDoorState;
  }
}

void loop()
{
  rcReceiveAndTransmit();
  irReceiveAndTransmit();
  processDoorAndTransmit();
  while(Firmata.available()) Firmata.processInput();
}
