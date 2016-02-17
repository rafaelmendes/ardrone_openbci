
class State(object):
    """Finite-State Machine.

    """

    def __init__(self, name):
        self.name = name


class Input(object):
    pass


class Transition(object):

    def transition(self, input):
        raise NotImplementedError('transition is not implemented yet!')


# define the states:
UNCONFIGURED = 0
CONFIGURED = 1
RUNNING = 2

# define the transitions
CONFIGURE = 0
START = 1
STOP = 2

# define the valdi transitions
# current state: transition -> next state
fsm = {
        UNCONFIGURED : [CONFIGURE, CONFIGURED],
        CONFIGURED : [START, RUNNING],
        RUNNING : [STOP, CONFIGURED]
}

class FSM(object):

    def __init__(self, state_transition_table, current_state):
        self.stt = state_transition_table
        self.curent_state = current_state

    def transition(self, transition):
        allowed_transitions = [t for t, s in self.stt.get(self.current_state, [])]
        if transition in allowed_transitions:
            next_state = [s for t, s in self.stt.get(self.current_state, [])]
            next_state = next_state[0]
            # make the call, or return the state or whatever
            self.current_state = next_state
        raise Error('Transition %s from %s not allowed' % (transition, self.current_state))
