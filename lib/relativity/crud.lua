local InsertManager = require('relativity.insert_manager')
local DeleteManager = require('relativity.delete_manager')
local UpdateManager = require('relativity.update_manager')
local SqlLiteral = require('relativity.nodes.sql_literal')
return {
  compile_insert = function(self, values)
    local im = self:create_insert()
    im:insert(values)
    return im
  end,
  create_insert = function(self)
    return InsertManager.new()
  end,
  compile_delete = function(self)
    local dm = DeleteManager.new()
    dm:wheres(self.ctx.wheres)
    dm:from(self.ctx.froms)
    return dm
  end,
  compile_update = function(self, values)
    local um = UpdateManager.new()
    local relation
    if values == SqlLiteral then
      relation = self.ctx.from
    else
      relation = values[1][1].relation
    end
    um:table(relation)
    um:set(values)
    if self.ast.limit then
      um:take(self.ast.limit.expr)
    end
    um:order(self.ast.orders)
    um:wheres(self.ctx.wheres)
    return um
  end
}
