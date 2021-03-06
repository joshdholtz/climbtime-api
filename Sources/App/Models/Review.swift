import Vapor
import Fluent
import Foundation

final class Review: Model {
	var id: Node?
	var title: String
	var rating: Int
	var text: String?
	var suggestedGrade: String?
	
	var userId: Int
	var routeId: Int
	
	var createdAt: PG.DateTime!
	var updatedAt: PG.DateTime!
	
	init(node: JSON, userId: Int) throws {
		id = try node.extract("id")
		title = try node.extract("title")
		rating = try node.extract("rating")
		text = try node.extract("text")
		suggestedGrade = try node.extract("suggested_grade")
		
		self.userId = userId
		routeId = try node.extract("route_id")
	}
	
	init(node: Node, in context: Context) throws {
		id = try node.extract("id")
		title = try node.extract("title")
		rating = try node.extract("rating")
		text = try node.extract("text")
		suggestedGrade = try node.extract("suggested_grade")
		
		userId = try node.extract("user_id")
		routeId = try node.extract("route_id")
		
		createdAt = try node.extract("created_at")
		updatedAt = try node.extract("updated_at")
	}
	
	func validate() throws {
		if try Review.query().filter("user_id", userId).filter("route_id", routeId).count() > 0 {
			throw Abort.custom(status: .badRequest, message: "Duplicate review")
		}
		
		if try User.find(userId) == nil {
			throw Abort.custom(status: .badRequest, message: "Invalid user")
		}
		
		if try Route.find(routeId) == nil {
			throw Abort.custom(status: .badRequest, message: "Invalid route")
		}
	}
	
	func patch(node: Node?) throws {
		guard let node = node else {
			return
		}
		
		try node.exists("title", { [unowned self] (s: String) in
			self.title = s
		})
		try node.exists("rating", { [unowned self] (s: Int) in
			self.rating = s
		})
		try node.exists("text", { [unowned self] (s: String?) in
			self.text = s
		})
		try node.exists("suggested_grade", { [unowned self] (s: String?) in
			self.suggestedGrade = s
		})
	}
	
	func makeNode(context: Context) throws -> Node {
		return try Node(node: [
			"id": id,
			"title": title,
			"rating": rating,
			"text": text,
			"suggested_grade": suggestedGrade,
			"user_id": userId,
			"route_id": routeId,
			"created_at": createdAt,
			"updated_at": updatedAt
			])
	}
	
	func willCreate() {
		createdAt = PG.DateTime()
		updatedAt = PG.DateTime()
	}
	
	func willUpdate() {
		updatedAt = PG.DateTime()
	}
}

extension Review: Preparation {
	static func prepare(_ database: Database) throws {
		
	}
	
	static func revert(_ database: Database) throws {
		
	}
}
