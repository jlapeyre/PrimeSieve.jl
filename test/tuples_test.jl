@test isadmtup([0,2,4]) == false
@test isadmtup([0,2,6,8,12]) == true
@test isadmtup([3, 5, 11, 17, 29]) == false
@test isadmtup([5, 7, 13, 19, 31]) == false
@test isadmtup([5,7,11,13,17]) == true

