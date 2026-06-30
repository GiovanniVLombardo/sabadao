import 'package:flutter/material.dart';
import 'package:sabadao/models/team.dart';
import 'package:sabadao/services/team_service.dart';



class TeamController extends ValueNotifier<List<Team>> {
  final TeamService _teamService;

  TeamController({TeamService? teamService})
      : _teamService = teamService ?? TeamService(),
        super([]);


  Future<List<Team>> getTeams() async {
    return _teamService.getTeams();
  }

}