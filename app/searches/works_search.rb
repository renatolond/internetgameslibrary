require 'chewy/query/filters'
class WorksSearch
	include ActiveModel::Model
	attr_accessor :query
	def index
		WorksIndex
	end

	def search
		query_string
	end

	def all
		index.filter{ match_all }
	end

	def query_string
		index.query(bool: {
				should: [
					{
						multi_match: {
							fields: [:original_title],# :author, :description],
							query: query,
							operator: "AND"
						}
					},
					{
						multi_match: {
							fields: [:original_title],#, :author, :description],
							query: query,
							fuzziness: "AUTO",
							operator: "AND"
						}
					}
				]
			}
		) if query.present?
	end
end
