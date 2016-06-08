# This python code implements a construction due to A. Bremner
# of a genus 2 curve with 4 properties:
# (1) Its Jacobian is isogenous to a product of elliptic curves
# (2) Each factor of the Jacobian has positive Mordell-Weil rank
# (3) real points and points modulo every prime
# (4) no points over the rational numbers.  
# Such a curve provides a counterexample to the Hasse principle, 
# and its lack of rational points can be explained by the 
# Brauer-Manin Obstruction.

# HOW TO USE THIS CODE

# First, we'll need MordellWeilSieve
import mordell_weil_sieve

# To find a curve satisfying the properties (1)-(4) above, you may simply run admissiblePairs().
# The function will output a pair of primes (p,q), and the curve X : y^2 = qx^6 - p satisfies the 
# above properties.

# PROOF

# Suppose (p,q) is an output of admissiblePairs() and X : y^2 = qx^6 - p is as above.

# (1) X has a map to an elliptic curve (send x to x^2), which implies its Jacobian splits as a product.
# (2) The elliptic curve factors and their ranks can be explicitly computed (not implemented).
# (3) By the Weil Conjectures, X is guaranteed to have local 
# solutions for all primes l >= 17.  We combine Quadratic Reciprocity and analysis at small primes 
# relative to p in order to choose q so that the curve has solutions at all primes.

# l=2:  (0,1)
# l=3:  q-p is a square mod 3
# l=5: +/-q - p is a square mod 5
# l=7:  q-p is a square mod 7
# l=11: +/-qx - p is a square mod 11.
# l=13:  +/-q-p is a square mod 13
# l=infinity:  y=0
# l=q:  q is chosen so that y^2 + p is reducible mod q.
# l=p:  (0,0)

# (4) Following Bremner, if q is chosen using the specialPrimes(p) method, then assuming the class number
# of K divides 6 non-trivially, X cannot have a rational point.  QED

# admissiblePairs(...) will output at most k^2 pairs (p,q) of primes such that the genus 2 curve y^2 = qx^6 - p has no 
# rational points but local points at all places.
def admissiblePairs(k=1, U=100):
	p_ = quadClassNumber(6,k,U);
	for p in p_:
		q_ = specialPrimes(p,k,U);
		for q in q_:
			J = MordellWeilSieve(EllipticCurve([0,-p*q^2]),0,1/q)
			if J.positiveRanks:
				print (p,q);	
			
# quadClassNumber(h): with optional arguments
# Returns a list of primes p <= U such that the class number of the (imaginary) quadratic extension
# generated by \sqrt{-p} is h.  By default only one value of p is returned.  For more examples,
# specify a value of k > 1.  The case h=6 was used by Bremner in his paper.
def quadClassNumber(h,k=1,U=100):
	primes = [];
	for p in Primes():
		if len(primes) == k or p > U:
			break;
		K = QuadraticField(-p);
		if K.class_number() == h:
			primes.append(p);
	return primes;

# specialPrimes(p): with optional arguments
# Given a prime p, returns at most k unramified primes q <= U which factor in the (imaginary) quadratic 
# extension generated by sqrt(-p) as a product of non-principal ideals.
#
# The loop over the sets S1 and S2 ensures local solubility.  It is exhaustive.
def specialPrimes(p,k=10,U=100, S1={3,7}, S2={5,13}):
	K = QuadraticField(-p);
	primes = [];
	for q in Primes():
		if q<5 or q==p: #we ignore 2 (the oddest prime), 3 (usual prime of bad reduction) and p (the obvious ramified prime)
			continue;
		elif len(primes) == k or q > U:
			break;
		else:
			for l in S1:
				if not(Mod(q-p,l).is_square()):
					break;
					
			for l in S2:
				if not(Mod(q-p,l).is_square() or Mod(-q-p,l).is_square()):
					break;
					
			for x in range(0,11):
				if Mod(q*x-p,11).is_square() or Mod(-q*x-p,11).is_square():
					P = K.primes_above(q); #there are 1 or 2 prime ideals contained in P.  
					if len(P)==2 and not(P[0].is_principal()):
						primes.append(q);
						break;
	return primes;  
