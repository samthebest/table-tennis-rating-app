package ttra

import scala.io.Source

case class Player(name: String, rating: Int = 0, wins: Int = 0, losses: Int = 0)

case class Game(winnerName: String, loserName: String, ts: Long = System.currentTimeMillis()) {
  def toTsv: String = winnerName + "\t" + loserName + "\t" + ts + "\t"
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

  def addPlayer(name: String): Unit = {
    // TODO require name is of form first.last so people can email each other
    approvedPlayerList = approvedPlayerList + name
  }

  def getPlayerList: Set[String] = approvedPlayerList
  def getGameLog: Vector[Game] = gameLog
  def getGameLogPretty: Vector[String] =
    gameLog.map(game => game.winnerName + "\t" + game.loserName + "\t" +
      new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new java.util.Date(game.ts)))

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
    case (m, Game(winnerName, loserName, _)) =>
      val winner = m.getOrElse(winnerName, Player(winnerName))
      val loser = m.getOrElse(loserName, Player(loserName))

      val adjustment = ratingAdjustment(winner.rating, loser.rating)

      m.updated(winnerName, updatePlayerWin(winner, adjustment))
      .updated(loserName, updatePlayerLose(loser, adjustment))
  }

  def sortedState: List[Player] = constructState.values.toList.sortBy(-_.rating)

  def export: String = gameLog.map(_.toTsv).mkString("\n")

  val path = "/usr/zeppelin/host-volume/fp-db.tsv"

  def load(): Unit = {
    gameLog =
      Source.fromFile(path).getLines().map(_.split("\t", -1).toList match {
        case winner :: loser :: ts :: Nil => Game(winner, loser, ts = ts.toLong)
        case _ => ???
      })
      .toVector

    approvedPlayerList = approvedPlayerList ++ gameLog.flatMap(g => List(g.winnerName, g.loserName))
  }

  def loadFromCSVString(s: String): Unit = {
    gameLog =
      s.split("\n").map(_.split(",", -1).toList match {
        case winner :: loser :: ts :: Nil => Game(winner, loser, ts = ts.toLong)
        case other => throw new IllegalArgumentException("UTS: " + other)
      })
      .toVector

    approvedPlayerList = approvedPlayerList ++ gameLog.flatMap(g => List(g.winnerName, g.loserName))
  }

  // Useful when people make a mistake
  def removeGame(game: Game): Unit = gameLog = gameLog.filter(_ != game)

  implicit class PimpedString(s: String) {
    def write(p: String): Unit = {
      val pw = new java.io.PrintWriter(new java.io.File(p))
      try pw.write(s) finally pw.close()
    }
  }

  // TODO Rotation (again, in case of mistake)
  def save(): Unit = export.write(path)

  def backup(): Unit = export.write(path + "." + System.currentTimeMillis())

  // Ideas: prizes should be awarded for players who:
  // 1. Increase in rank the most
  // 2. Play the most number of different players
  // 3. Play the most number of new players
}


//case class DropDownMenu(id: String, label: String)
//
//import TTRA._
//
//try {
//  load()
//} catch {
//  case e: Throwable => println("Load failed, try importing history")
//}


//val playersMenuOptions = getPlayerList.toArray.map(name => DropDownMenu(name, name))
//z.angularBind("myOptions", playersMenuOptions)
//z.angularBind("selectedOptionWinner", Array(DropDownMenu("NOT SELECTED", "NOT SELECTED")))
//z.angularBind("selectedOptionLoser", Array(DropDownMenu("NOT SELECTED", "NOT SELECTED")))



//%angular
//<label>THE MIGHTY WINNER:</label><select name="mySelectWinner" style="background-color:transparent" ng-options="opt.id as opt.label for opt in myOptions" ng-model="selectedOptionWinner"></select>
//<label>THE PATHETIC WORTHLESS LOSER:</label><select name="mySelectLoser" style="background-color:transparent" ng-options="opt.id as opt.label for opt in myOptions" ng-model="selectedOptionLoser"></select>




//reset()
//load()
//val winner = z.angular("selectedOptionWinner").toString
//val loser = z.angular("selectedOptionLoser").toString
//if (winner == null || loser == null || winner == "" || loser == "" || winner == "NOT SELECTED" || loser == "NOT SELECTED" || winner.contains("DropDownMenu") || loser.contains("DropDownMenu")) {
//  println(".")
//  println("ERROR: User too stupid, or try refreshing/clearing cache")
//} else {
//  addGame(winner, loser)
//  save()
//  println("SUCCESS! Well done you added a game, run the Rankings cell to see how crap you are!")
//  println("Most recent 10 games:")
//  getGameLogPretty.takeRight(10).foreach(println)
//}




//z.show(sqlContext.createDataFrame(sortedState))


//z.show(sqlContext.createDataFrame(getGameLog.toList))
