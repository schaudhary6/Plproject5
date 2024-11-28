%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper predicates
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if a door is passable directly (unlocked door).
% CurrentRoom and NextRoom are connected by a door in either direction.
passable(CurrentRoom, NextRoom, _) :-
    door(CurrentRoom, NextRoom);
    door(NextRoom, CurrentRoom).

% Check if a locked door is passable given the available keys.
% If the door is locked with a specific color, verify if the corresponding key is in the Keys list.
passable(CurrentRoom, NextRoom, Keys) :-
    (locked_door(CurrentRoom, NextRoom, LockColor);
     locked_door(NextRoom, CurrentRoom, LockColor)),
    member(LockColor, Keys). % Check if the key for the lock is available.

% Add a key to the list of collected keys if it is present in the current room and not already picked up.
pickup_keys(CurrentRoom, Keys, UpdatedKeys) :-
    (key(CurrentRoom, KeyColor), \+ member(KeyColor, Keys) ->
        UpdatedKeys = [KeyColor | Keys]; % Add the key if not already collected.
        UpdatedKeys = Keys).

% Base case for BFS: If the treasure is found in the current room, return the path taken.
bfs([[Path, CurrentRoom, _] | _], Path) :-
    treasure(CurrentRoom).

% Recursive case for BFS: Explore all possible moves from the current room.
bfs([[Path, CurrentRoom, Keys] | RestQueue], Solution) :-
    findall(
        [NewPath, NextRoom, UpdatedKeys],
        (
            passable(CurrentRoom, NextRoom, Keys),       % Check if the door is passable.
            \+ member(move(CurrentRoom, NextRoom), Path), % Avoid revisiting the same move.
            pickup_keys(NextRoom, Keys, UpdatedKeys),     % Collect keys in the next room if available.
            append(Path, [move(CurrentRoom, NextRoom)], NewPath) % Append the move to the current path.
        ),
        NewPaths
    ),
    append(RestQueue, NewPaths, NewQueue), % Add new paths to the queue for further exploration.
    bfs(NewQueue, Solution). % Continue searching with the updated queue.

% Entry point for the search algorithm.
search(Actions) :-
    initial(StartRoom), % Retrieve the starting room from the scenario.
    bfs([[[ ], StartRoom, []]], Actions). % Initialize BFS with an empty path and no keys.
