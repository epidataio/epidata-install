#!/bin/sh
exec scala "$0" "$@"
!#
import java.security.SecureRandom
val random = new SecureRandom()
val key = (1 to 64).map { _ => (random.nextInt(75) + 48).toChar}.mkString.replaceAll("\\\\+", "/")

println(key)