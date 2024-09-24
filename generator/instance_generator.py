
import json
import re
import os

import networkx as nx 
import matplotlib.pyplot as plt

from pathlib import Path
from typing import List, Union, Tuple, Dict

from generator.option_enums import (LengthOption, LocationOption, ConcurrencyOption, 
                                    MovementOption, CostOption, Goal, Direction,
                                    ParkOption)
from generator.pddl_objects import Track, Train, Driver


class ShuntingYard:

    def __init__(self,
                 cost_option: CostOption,
                 length_option: LengthOption,
                 location_option: LocationOption,
                 concurrency_option: ConcurrencyOption,
                 movement_option: MovementOption,
                 walking_distances: Dict[Tuple[str, str], int],
                 switches_included: bool,
                 unique_entry_distance: bool,
                 domain_name: str = "",
                 problem_name: str = ""):
        
        self.cost_option = cost_option
        self.length_option = length_option
        self.location_option = location_option
        self.concurrency_option = concurrency_option
        self.movement_option = movement_option
        self.walking_distances = walking_distances
        self.switches_included = switches_included
        self.unique_entry_distance = unique_entry_distance
        self.domain_name = domain_name
        self.problem_name = problem_name

        self.tracks: List[Track] = []
        self.track_connections: List[Tuple[str, str]] = []
        self.trains: List[Train] = []
        self.train_entry_order = dict()
        self.train_exit_order = dict()
        self.train_goal = dict()
        self.drivers: List[Driver] = []
        self.entry_conn_dir = Direction.ASIDE

        self.graph = nx.Graph()


    def load_location_json(self, filename: str):

        with open(filename, 'r') as f:
            json_txt = f.read()
        obj = json.loads(json_txt)

        tracks = obj['trackParts']
        for track in tracks:
            track['name'] = re.sub('[^0-9a-zA-Z]+', '_', track['name'])

        allowed_types = ["RailRoad"]
        if self.switches_included:
            allowed_types += ["Switch", "EnglishSwitch"]

        def find_aside_connection(track, tracks, connections):
            aside_connections = track['aSide']
            for aside_conn_id in aside_connections:
                aside_conn = next(t for t in tracks if t['id'] == aside_conn_id)
                if aside_conn['type'] in allowed_types:
                    connections.add(aside_conn['name'])
                else:
                    connections.union(find_aside_connection(aside_conn, tracks, connections))
            return connections 
            
        links = []
        tracks_filtered = []
        for track in tracks:

            track['name'] = re.sub('[^0-9a-zA-Z]+', '_', track['name'])

            if track['type'] not in allowed_types:
                continue

            tracks_filtered.append((track['name'], int(track['length']), track['parkingAllowed']))

            aside_tracks = find_aside_connection(track, tracks, set())
            for other in aside_tracks:
                links.append((track['name'], other))

        for name, length, parking in sorted(tracks_filtered, key=lambda x: x[0]):
            self.add_track(name, length, parking)

        for aside, bside in links:
            self.connect_tracks(aside, bside)

    def get_track_names(self) -> List[str]:
        return [t.name for t in self.tracks]
    
    def get_track(self, name) -> Track:
        return next((t for t in self.tracks if t.name == name), None)

    def add_track(self, name, length, parking=True, service=False, is_entry=False):
        if name in self.get_track_names():
            raise Exception(f"Trying to add duplicate track name: {name}")
        self.tracks.append(Track(name, length, parking, service, is_entry))
        self.graph.add_node(name)

    def connect_tracks(self, name_aside, name_bside):
        assert name_aside in self.get_track_names()
        assert name_bside in self.get_track_names()
        self.track_connections.append((name_aside, name_bside))
        self.graph.add_edge(name_aside, name_bside)

    def load_train_json(self, filename: str):

        with open(filename, 'r') as f:
            json_txt = f.read()
        obj = json.loads(json_txt)

        arrivals = obj['arrivals']
        departures = obj['departures']

        
        self.trains = []
        for i, departure in enumerate(departures):
            name = departure['name']
            
            if self.entry_conn_dir == Direction.ASIDE:
                self.train_exit_order[name] = i+1
            elif self.entry_conn_dir == Direction.BSIDE:
                self.train_exit_order[name] = len(departures)-i
            self.add_train(**departure, priority=i+1)

        for i, arrival in enumerate(arrivals):
            if name not in self.get_train_names():
                raise Exception(f'Departing train "{departure['name']}" not in list of arrivals')
            self.train_entry_order[arrival['name']] = i

    def get_train_names(self) -> List[str]:
        return [t.name for t in self.trains]
    
    def get_train(self, name) -> Train:
        return next((t for t in self.trains if t.name == name), None)
    
    def add_train(self, name, length, priority, available=True):
        if name in self.get_train_names():
            raise Exception(f"Trying to add duplicate train name: {name}")
        self.trains.append(Train(name, length, priority))

    def get_max_train_length(self):
        return max(t.length for t in self.trains)
    
    def get_min_train_length(self):
        return min(t.length for t in self.trains)
    
    def set_service_tracks(self, names: List[str]):
        for name in names:
            track = self.get_track(name)
            if track is None:
                raise Exception(f"Could not find track with name {name}")
            self.rename_track(track.name, track.name + "_service")
            track.service = True
            track.parking = False

    def rename_track(self, name: str, new_name: str):
        track = self.get_track(name)
        if track is None:
            raise Exception("Cannot rename track that does not exist")
        self.graph = nx.relabel_nodes(self.graph, {name: new_name})
        track.name = new_name
        for i in range(len(self.track_connections)):
            aside, bside = self.track_connections[i]
            if bside == name:
                bside = new_name
            elif aside == name:
                aside = new_name
            self.track_connections[i] = (aside, bside)

    def add_drivers(self, names: List[str]):
        for name in names:
            self.drivers.append(Driver(name))

    def add_entry_track(self, conns: List[str], conn_dir: Direction):
        assert all(t in self.get_track_names() for t in conns)

        if self.location_option == LocationOption.RELATIVE:
            length = 0
        else:
            length = sum([t.length for t in self.trains])

        self.add_track("entry", length, False, False, True)

        self.entry_conn_dir = conn_dir

        for conn in conns:
            if conn_dir == Direction.ASIDE:
                self.connect_tracks("entry", conn)
            else:
                self.connect_tracks(conn, "entry")

    def add_goal(self, train_name: str, goal: Goal):
        train = self.get_train(train_name)
        if train is None:
            raise Exception(f"Could not find train with name {train_name}")
        
    def set_all_goals(self, goals: List[Goal]):
        for train in self.trains:
            train.goals = goals

    def remove_tracks(self, names: List[str]):
        self.tracks = [t for t in self.tracks if all(t.name != n for n in names)]
        self.track_connections = [c for c in self.track_connections if all(c[0] != n for n in names) and all(c[1] != n for n in names)]
        for n in names:
            self.graph.remove_node(n)

    def simplify_track_lengths(self):
        max_len = self.get_max_train_length()
        min_len = self.get_min_train_length()
        if max_len == min_len:
            for track in self.tracks:
                if track.length < min_len:
                    track.length = min_len
                    track.parking = False
                else:
                    track.length = int(int(track.length/min_len)*min_len)
                if track.service:
                    track.length = min_len

    def visualize(self, savename=None, figsize=(20,10)):
        self.graph.nodes['entry']['layer'] = 0
        next_tracks = ["entry"]
        done_tracks = []
        while len(next_tracks) > 0:
            track = next_tracks.pop(0)
            done_tracks.append(track)
            for bside, aside in self.track_connections:
                if bside == track and aside not in done_tracks:
                    self.graph.nodes[aside]['layer'] = self.graph.nodes[track]['layer'] + 1
                    done_tracks.append(aside)
                    next_tracks.append(aside)
                elif aside == track and bside not in done_tracks:
                    self.graph.nodes[bside]['layer'] = self.graph.nodes[track]['layer'] - 1
                    done_tracks.append(bside)
                    next_tracks.append(bside)
            next_tracks = sorted(next_tracks)
            
        plt.figure(figsize=figsize) 
        pos = nx.multipartite_layout(self.graph, subset_key='layer')
        nx.draw(self.graph, pos, with_labels=True)

        if savename is not None:
            plt.savefig('ShuntingYard.png')
            plt.close()
        else:
            plt.show()
        


    def generate(self):
        # self.simplify_track_lengths()

        lines = ["(define", 
                    f"(problem {self.problem_name})", 
                    f"(:domain {self.domain_name})",
                    "(:objects", ""]
        
        if self.location_option == LocationOption.EXACT and self.movement_option == MovementOption.END_OF_TRACK:
            for t in self.tracks:
                if t.entry_distance == 0:
                    t.length = sum([train.length for train in self.trains])
        
        if self.concurrency_option == ConcurrencyOption.DRIVER_OBJECTS:
            lines += [d.object_name() for d in self.drivers]
        lines += [t.object_name(self.length_option) for t in self.trains]
        lines += [t.object_name(self.length_option) for t in self.tracks]

        lines += ["", ")", "", "(:init", ""]

        if self.concurrency_option == ConcurrencyOption.DRIVER_OBJECTS:
            for driver in self.drivers:
                lines += driver.init_fluents(self.walking_distances is not None)
        elif self.concurrency_option == ConcurrencyOption.NUMERIC_FLUENT:
            lines += [f"\t(= (max_concurrent_movements) {len(self.drivers)})"]
            lines += [f"\t(= (concurrent_movements) 0)"]

        entry_track = self.get_track("entry")
        entry_track.num_trains = len(self.trains)
        max_length = max([t.length for t in self.trains])
        shortest_paths = list()
        for track in self.tracks:
            sp = int(nx.shortest_path_length(self.graph, track.name, 'entry'))
            if self.unique_entry_distance:
                while sp in shortest_paths:
                    sp += 0.01
                shortest_paths.append(sp)
            sp = round(sp,2)
            lines += track.init_fluents(self.length_option, self.location_option, 
                                        self.movement_option, sp, max_length=max_length)

        lines += ["", "\t; track connections", "\t; ===================="]


        for aside, bside in self.track_connections:
            lines += [f"\t(track_connected track_{aside} track_{bside})"]

        lines += [""]
        
        total_distance = 0
        for train in self.trains:
            if Goal.AHEAD in train.goals:
                train.priority = None
            if self.movement_option == MovementOption.END_OF_TRACK:
                if self.entry_conn_dir == Direction.ASIDE:
                    distance = total_distance
                elif self.entry_conn_dir == Direction.BSIDE:
                    distance = sum([t.length for t in self.trains]) - total_distance - train.length
            else:
                distance = None
            lines += train.init_fluents(self.length_option, 
                                        self.location_option, 
                                        self.concurrency_option,
                                        distance, 
                                        self.train_exit_order[train.name])
            total_distance += train.length

        if self.walking_distances is not None:
            dist_pairs_added = []
            singles_added = []
            for ((t1, t2), dist) in self.walking_distances.items():
                if t1 not in singles_added:
                    lines += [f"\t(= (walking_distance track_{t1} track_{t1}) 0)"]
                    singles_added.append(t1)
                if t2 not in singles_added:
                    lines += [f"\t(= (walking_distance track_{t2} track_{t2}) 0)"]
                    singles_added.append(t2)
                if (t1, t2) not in dist_pairs_added:
                    lines += [f"\t(= (walking_distance track_{t1} track_{t2}) {dist})"]
                    dist_pairs_added.append((t1, t2))
                if (t2, t1) not in dist_pairs_added:
                    lines += [f"\t(= (walking_distance track_{t2} track_{t1}) {dist})"]
                    dist_pairs_added.append((t2, t1))

        lines += [")", "(:goal (and", ""]

        trains_ordered = sorted(self.train_exit_order.keys(), key=lambda x: self.train_exit_order[x], reverse=True)

        for train in self.trains:
            if Goal.AHEAD_ALL in train.goals:
                lines += [f"\t(ahead_all)"]
                break
            if Goal.AHEAD in train.goals:
                train.priority = None
            for goal in train.goals:
                if goal == Goal.SERVICED_AND_PARKED and Goal.AHEAD not in train.goals:
                    if self.entry_conn_dir == Direction.ASIDE:
                        lines += [f"\t(serviced_and_parked_bside train_{train.name})"]
                    elif self.entry_conn_dir == Direction.BSIDE:
                        lines += [f"\t(serviced_and_parked_aside train_{train.name})"]
                elif goal == Goal.SERVICED:
                    lines += [f"\t(serviced train_{train.name})"]
                elif goal == Goal.PARKED:
                    lines += [f"\t(parked train_{train.name})"]
                elif goal == Goal.AHEAD:
                    exit_idx = trains_ordered.index(train.name)
                    if exit_idx < (len(trains_ordered)-1):
                        if self.entry_conn_dir == Direction.ASIDE:
                            lines += [f"\t(ahead_bside train_{train.name} train_{trains_ordered[exit_idx+1]})"]
                        elif self.entry_conn_dir == Direction.BSIDE:
                            lines += [f"\t(ahead_aside train_{train.name} train_{trains_ordered[exit_idx+1]})"]
                elif goal == Goal.AT_ENTRY:
                    lines += [f"\t(train_at train_{train.name} track_entry)"]
                elif goal == Goal.ORDER:
                    exit_idx = trains_ordered.index(train.name)
                    if exit_idx < (len(trains_ordered)-1):
                        if self.entry_conn_dir == Direction.ASIDE:
                            lines += [f"\t(> (order train_{train.name}) (order train_{trains_ordered[exit_idx+1]}))"]
                        elif self.entry_conn_dir == Direction.BSIDE:
                            lines += [f"\t(< (order train_{train.name}) (order train_{trains_ordered[exit_idx+1]}))"]


        lines += [""]    

        lines += ["", "))", ")"]

        filename = Path(self.problem_name+".pddl")
        filename.touch(exist_ok=True) 

        if os.path.exists(filename):
            os.remove(filename)

        with open(filename, 'w+') as f:
            f.write("\n".join(lines))
