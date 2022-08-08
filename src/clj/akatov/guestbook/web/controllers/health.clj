(ns akatov.guestbook.web.controllers.health
  (:require
   [clojure.tools.logging :as log]
   [ring.util.http-response :as http-response])
  (:import
   [java.util Date]))

(defonce num-requests (atom 0))

(defn healthcheck!
  [req]
  (swap! num-requests + 1)
  (log/info (str "and another request. total requests: " @num-requests))
  (http-response/ok
   {:time     (str (Date. (System/currentTimeMillis)))
    :up-since (str (Date. (.getStartTime (java.lang.management.ManagementFactory/getRuntimeMXBean))))
    :app      {:status  "up"
               :message ""
               :num-requests @num-requests}}))
