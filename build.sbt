
val companyName = "ttra"
val domain = "com"

resolvers ++= Seq(
  "spray repo" at "http://repo.spray.io"
)

Defaults.itSettings

lazy val `it-config-sbt-project` = project.in(file(".")).configs(IntegrationTest.extend(Test))

scalaVersion := "2.11.8"

libraryDependencies ++= Seq(
  "org.scalacheck" %% "scalacheck" % "1.12.1" % "it,test" withSources() withJavadoc(),
  "org.specs2" %% "specs2-core" % "2.4.15" % "it,test" withSources() withJavadoc(),
  "org.specs2" %% "specs2-scalacheck" % "2.4.15" % "it,test" withSources() withJavadoc(),
  "org.scalaz" %% "scalaz-core" % "7.1.0" withSources() withJavadoc(),
  //
  "org.apache.commons" % "commons-math3" % "3.2" withSources() withJavadoc()
)


javaOptions ++= Seq("-target", "1.8", "-source", "1.8")

name := "ttra"

parallelExecution in Test := false

version := "0.1.0"
