class GamesIndex < Chewy::Index
	settings analysis: {
		filter: {
			my_synonym_filter: {
				type: "synonym",
				synonyms: [
					"littlebigplanet,little big planet",
					"megaman,mega man",
					"i,1",
					"ii,2",
					"iii,3",
					"iv,4",
					"v,5",
					"vi,6",
					"vii,7",
					"viii,8",
					"ix,9",
					"x,10",
					"xi,11",
					"xii,12",
					"xiii,13",
					"xiv,14",
					"xv,15",
					"xvi,16",
					"xvii,17",
					"xviii,18",
					"xix,19",
					"xx,20"
				]
			}
		},
		analyzer: {
			title: {
				tokenizer: 'standard',
				filter: ['lowercase', 'asciifolding', "my_synonym_filter"]
			}
		}
	}

	define_type Expansion.includes(edition: [:genres, :platform, :region, :work]) do
		field :title, analyzer: 'title'
		field :release_date, type: 'date'
		field :original_title, value: ->{ edition.work.original_title }
		field :original_release_date, value: ->{ edition.work.original_release_date }
		field :platform, value: ->{ edition.platform.title }
		field :platform_id, value: -> { edition.platform_id }, type: 'integer'
		field :region, value: ->{ edition.region.title }
		field :region_id, value: ->{ edition.region_id }, type: 'integer'
		field :description
		field :genres, index: 'not_analyzed', value: ->{ edition.genres.map(&:title) }
		field :created_at, value: ->{ created_at.to_i }, type: 'integer'
	end

	define_type Edition.includes(:genres, :platform, :region, :work) do
		field :title, analyzer: 'title'
		field :release_date, type: 'date'
		field :original_title, value: ->{ work.original_title }
		field :original_release_date, value: ->{ work.original_release_date }
		field :work_id, type: 'integer'
		field :platform, value: ->{ platform.title }
		field :platform_id, type: 'integer'
		field :region, value: ->{ region.title }
		field :region_id, type: 'integer'
		field :description
		field :genres, index: 'not_analyzed', value: ->{ genres.map(&:title) }
		field :created_at, value: ->{ created_at.to_i }, type: 'integer'
	end
end
