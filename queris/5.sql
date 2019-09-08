select trip.tripid,verificationStatus 
from verificationtripbyspecialist, specialist,trip
where verificationStatus = "rejected" and 
      trip.tripid= verificationtripbyspecialist.tripid and
      specialist.specialistssn= verificationtripbyspecialist.specialistssn