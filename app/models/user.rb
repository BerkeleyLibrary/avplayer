# Represents a user in our system
#
# This is closely coupled to CalNet's user schema.
class User
  include ActiveModel::Model
  include BerkeleyLibrary::Logging

  # ------------------------------------------------------------
  # Constants

  # 'NOT REGISTERED' = summer session / concurrent enrollment / early in the semester
  # NOTE: CalNet docs are contradictory about whether there should be a dash after NOT,
  #       so for now we should handle both. See:
  #
  #       - https://calnetweb.berkeley.edu/calnet-technologists/ldap-directory-service/how-ldap-organized/people-ou/people-ou-affiliations#Student
  #       - see https://calnetweb.berkeley.edu/calnet-technologists/single-sign/cas/casify-your-web-application-or-web-server
  STUDENT_AFFILIATIONS = [
    'STUDENT-TYPE-REGISTERED',
    'STUDENT-TYPE-NOT REGISTERED',
    'STUDENT-TYPE-NOT-REGISTERED'
  ].freeze

  SESSION_ATTRS = %i[uid affiliations].freeze

  # ------------------------------------------------------------
  # Initializer

  # @param uid The CalNet UID
  # @param affiliations Affiliations per CalNet (attribute `berkeleyEduAffiliations` e.g.
  #        `EMPLOYEE-TYPE-FACULTY`, `STUDENT-TYPE-REGISTERED`).
  def initialize(uid: nil, affiliations: nil)
    super
  end

  # ------------------------------------------------------------
  # Class methods

  class << self
    def from_omniauth(auth)
      ensure_valid_provider(auth['provider'])

      new(
        uid: auth['extra']['uid'], # TODO: why not auth['uid']?
        affiliations: auth['extra']['berkeleyEduAffiliations']
      )
    end

    def from_session(session)
      attr_hash = (session && session[:user]) || {}
      new(**attr_hash.symbolize_keys.slice(*SESSION_ATTRS))
    end

    private

    def ensure_valid_provider(provider)
      raise Error::InvalidAuthProviderError, provider if provider.to_sym != :calnet
    end
  end

  # ------------------------------------------------------------
  # Accessors

  # Affiliations per CalNet (attribute `berkeleyEduAffiliations` e.g.
  # `EMPLOYEE-TYPE-FACULTY`, `STUDENT-TYPE-REGISTERED`).
  #
  # Not to be confused with {Patron::Record#affiliation}, which returns
  # the patron affiliation according to the Millennium patron record
  # `PCODE1` value.
  #
  # @return [String]
  attr_accessor :affiliations

  # @return [String]
  attr_accessor :uid

  # ------------------------------------------------------------
  # Instance methods

  # Whether the user was authenticated
  #
  # The user object is PORO, and we always want to be able to return it even in
  # cases where the current (anonymous) user hasn't authenticated. This method
  # is provided as a convenience to tell if the user's actually been auth'd.
  #
  # @return [Boolean]
  def authenticated?
    !uid.nil?
  end

  # TODO: do we care?
  #
  # def ucb_faculty?
  #   affiliations&.include?('EMPLOYEE-TYPE-ACADEMIC')
  # end
  #
  # def ucb_staff?
  #   affiliations&.include?('EMPLOYEE-TYPE-STAFF')
  # end
  #
  # def ucb_student?
  #   return unless affiliations
  #
  #   STUDENT_AFFILIATIONS.any? { |a9n| affiliations.include?(a9n) }
  # end

  def authorized?
    authenticated? # && (ucb_student? || ucb_staff? || ucb_faculty?)
  end

  def inspect
    attrs = %i[uid affiliations].map { |attr| "#{attr}: #{send(attr).inspect}" }.join(', ')
    "User@#{object_id}(#{attrs})"
  end
end
