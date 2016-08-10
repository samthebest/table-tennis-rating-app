package ttra

import TTRA._
import org.specs2.mutable.Specification

class TTRASpecs extends Specification {
  "TTRA.ratingAdjustment" should {
    // http://www.teamusa.org/usa-table-tennis/ratings/how-does-the-usatt-rating-system-work

    "Return correct values for lower buckets" in {
      ratingAdjustment(100, 100) must_=== 8

      ratingAdjustment(100, 90) must_=== 8
      ratingAdjustment(90, 100) must_=== 8

      ratingAdjustment(100, 80) must_=== 7
      ratingAdjustment(0, 37) must_=== 10

      ratingAdjustment(49, 9) must_=== 6
      ratingAdjustment(9, 49) must_=== 13
    }

    "Return correct values for higher buckets" in {
      ratingAdjustment(100, 312) must_=== 40
      ratingAdjustment(312, 100) must_=== 1

      ratingAdjustment(100, 320) must_=== 45
      ratingAdjustment(320, 100) must_=== 1

      ratingAdjustment(100, 338) must_=== 50
      ratingAdjustment(338, 100) must_=== 0

      ratingAdjustment(100, 350) must_=== 50
      ratingAdjustment(10000000, 100) must_=== 0
    }
  }

  "TTRA.constructState" should {
    "Construct correct state for interesting history" in {
      addPlayer("bob")
      addPlayer("harry")
      addPlayer("henry")
      addPlayer("alice")
      addPlayer("adam")
      addPlayer("john")
      addPlayer("fred")
      addPlayer("sarah")

      reset()
      addGame(winnerName = "bob", "henry")
      addGame(winnerName = "bob", "alice")
      addGame(winnerName = "bob", "harry")
      addGame(winnerName = "harry", "alice")
      addGame(winnerName = "harry", "henry")
      addGame(winnerName = "harry", "bob")
      addGame(winnerName = "bob", "harry")
      addGame(winnerName = "harry", "henry")
      addGame(winnerName = "harry", "adam")
      addGame(winnerName = "alice", "bob")
      addGame(winnerName = "bob", "harry")
      addGame(winnerName = "bob", "harry")
      addGame(winnerName = "harry", "henry")
      addGame(winnerName = "henry", "harry")
      addGame(winnerName = "john", "adam")
      addGame(winnerName = "fred", "alice")
      addGame(winnerName = "harry", "fred")
      addGame(winnerName = "alice", "harry")
      addGame(winnerName = "sarah", "bob")
      addGame(winnerName = "alice", "fred")
      addGame(winnerName = "bob", "harry")
      addGame(winnerName = "harry", "adam")
      addGame(winnerName = "fred", "john")
      addGame(winnerName = "bob", "sarah")
      addGame(winnerName = "bob", "henry")
      addGame(winnerName = "henry", "harry")
      addGame(winnerName = "fred", "alice")

      sortedState must_===
        List(
          Player("bob", 42, 9, 3),
          Player("fred", 16, 3, 2),
          Player("alice", 12, 3, 4),
          Player("henry", 11, 2, 5),
          Player("sarah", 3, 1, 1),
          Player("harry", 1, 8, 8),
          Player("john", 0, 1, 1),
          Player("adam", 0, 0, 3)
        )

      addGame(winnerName = "bob", "harry")

      sortedState must_=== List(
        Player("bob", 48, 10, 3),
        Player("fred", 16, 3, 2),
        Player("alice", 12, 3, 4),
        Player("henry", 11, 2, 5),
        Player("sarah", 3, 1, 1),
        Player("john", 0, 1, 1),
        Player("adam", 0, 0, 3),
        Player("harry", 0, 8, 9)
      )
    }
  }
}
