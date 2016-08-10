package ttra

case class Player(name: String, rating: Int = 0, wins: Int = 0, losses: Int = 0)

case class Game(winnerName: String, loserName: String, points: Option[List[(Int, Int)]] = None, ts: Long = System.currentTimeMillis()) {
  def toTsv: String = winnerName + "\t" + loserName + "\t" + ts + "\t" + points.map(_.map(_.productIterator.toList.mkString(";")).mkString(",")).getOrElse("")
}

// http://www.teamusa.org/usa-table-tennis/ratings/how-does-the-usatt-rating-system-work
object TTRA {

  private var gameLog: Vector[Game] = Vector.empty
  // Prevents typos
  private var approvedPlayerList: Set[String] = Set.empty

  def addGame(winnerName: String, loserName: String): Unit = {
    require(approvedPlayerList(winnerName), "ERROR: Name spelt wrong, or not in approved list: " + winnerName)
    require(approvedPlayerList(loserName), "ERROR: Name spelt wrong, or not in approved list: " + loserName)
    gameLog = gameLog :+ Game(winnerName, loserName)
  }

  def addGame(winnerName: String, loserName: String, points: List[(Int, Int)]): Unit = {
    require(approvedPlayerList(winnerName), "ERROR: Name spelt wrong, or not in approved list: " + winnerName)
    require(approvedPlayerList(loserName), "ERROR: Name spelt wrong, or not in approved list: " + loserName)
    gameLog = gameLog :+ Game(winnerName, loserName, Some(points))
  }

  def addPlayer(name: String): Unit = {
    // TODO require name is of form first.last so people can email each other
    approvedPlayerList = approvedPlayerList + name
  }

  def reset(): Unit = gameLog = Vector.empty

  def ratingAdjustment(winner: Int, loser: Int): Int = (math.abs(winner - loser), winner > loser) match {
    case (diff, true) if diff <= 12 => 8
    case (diff, false) if diff <= 12 => 8

    case (diff, true) if diff <= 37 => 7
    case (diff, false) if diff <= 37 => 10

    case (diff, true) if diff <= 62 => 6
    case (diff, false) if diff <= 62 => 13

    case (diff, true) if diff <= 87 => 5
    case (diff, false) if diff <= 87 => 16

    case (diff, true) if diff <= 112 => 4
    case (diff, false) if diff <= 112 => 20

    case (diff, true) if diff <= 137 => 3
    case (diff, false) if diff <= 137 => 25

    case (diff, true) if diff <= 162 => 2
    case (diff, false) if diff <= 162 => 30

    case (diff, true) if diff <= 187 => 2
    case (diff, false) if diff <= 187 => 35

    case (diff, true) if diff <= 212 => 1
    case (diff, false) if diff <= 212 => 40

    case (diff, true) if diff <= 237 => 1
    case (diff, false) if diff <= 237 => 45

    case (_, true) => 0
    case (_, false) => 50
  }

  def updatePlayerWin(player: Player, adjustment: Int): Player =
    player.copy(rating = player.rating + adjustment, wins = player.wins + 1)

  def updatePlayerLose(player: Player, adjustment: Int): Player = {
    if (player.rating - adjustment >= 0) player.copy(rating = player.rating - adjustment, losses = player.losses + 1)
    else player.copy(rating = 0, losses = player.losses + 1)
  }

  // When gameLog gets large we will probably want to put some caching logic in
  def constructState: Map[String, Player] = gameLog.foldLeft(Map.empty[String, Player]) {
    case (m, Game(winnerName, loserName, _, _)) =>
      val winner = m.getOrElse(winnerName, Player(winnerName))
      val loser = m.getOrElse(loserName, Player(loserName))

      val adjustment = ratingAdjustment(winner.rating, loser.rating)

      m.updated(winnerName, updatePlayerWin(winner, adjustment))
      .updated(loserName, updatePlayerLose(loser, adjustment))
  }

  def sortedState: List[Player] = constructState.values.toList.sortBy(-_.rating)

  def export: String = gameLog.map(_.toTsv).mkString("\n")

  val path = "/usr/zeppelin/host-volume/fp-db.tsv"

  // Excercise for Dan
  def load(): Unit = ??? // Source.fromFile(path).getLines().map ...

  implicit class PimpedString(s: String) {
    def write(p: String): Unit = {
      val pw = new java.io.PrintWriter(new java.io.File(p))
      try pw.write(s) finally pw.close()
    }
  }

  def save(): Unit = export.write(path)

  // Ideas: prizes should be awarded for players who:
  // 1. Increase in rank the most
  // 2. Play the most number of different players
  // 3. Play the most number of new players
}