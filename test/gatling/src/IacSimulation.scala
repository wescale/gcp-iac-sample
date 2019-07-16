package iac

import io.gatling.core.Predef._ 
import io.gatling.http.Predef._
import scala.concurrent.duration._

class IacSimulation extends Simulation { 

  val httpProtocol = http
    .baseUrl("http://dev-2.gcp-wescale.slavayssiere.fr") 
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8") 
    .doNotTrackHeader("1")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0")

  val scn = scenario("IacSimulation") 
    .exec(http("root") 
      .get("/"))  
    .exec(http("facture") 
      .get("/facture"))  
    .exec(http("client") 
      .get("/client"))  
    .exec(http("ips") 
      .get("/ips")) 
    .pause(1)
    .exec(http("root") 
      .get("/"))  
    .exec(http("facture") 
      .get("/facture"))  
    .exec(http("client") 
      .get("/client"))  
    .exec(http("ips") 
      .get("/ips")) 

  setUp(
    scn.inject(atOnceUsers(1000))
  ).protocols(httpProtocol)
}