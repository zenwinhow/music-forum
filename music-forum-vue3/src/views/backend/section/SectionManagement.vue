<template>
  <div class="section-management">
    <el-card>
      <div style="display:flex;justify-content:space-between;align-items:center;">
        <h3>音乐分类管理</h3>
        <el-button type="primary" @click="openAdd">新增分类</el-button>
      </div>
      <el-table :data="tableData" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="sectionName" label="分类名" />
        <el-table-column prop="description" label="描述" />
        <el-table-column label="状态" width="110">
          <template #default="{row}"><el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="v=>changeStatus(row.id,v)"/></template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button type="primary" link @click="openEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialog" title="分类">
      <el-form :model="form" label-width="80px">
        <el-form-item label="名称"><el-input v-model="form.sectionName"/></el-form-item>
        <el-form-item label="描述"><el-input v-model="form.description" type="textarea"/></el-form-item>
      </el-form>
      <template #footer><el-button @click="dialog=false">取消</el-button><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const tableData = ref([])
const dialog = ref(false)
const form = reactive({ id: null, sectionName: '', description: '', status: 1 })

const load = async () => {
  await request.get('/section/all', { status: -1 }, { showDefaultMsg: false, onSuccess: r => tableData.value = r || [] })
}

const changeStatus = async (id, status) => {
  await request.put(`/section/${id}/status?status=${status}`, null, { showDefaultMsg: false })
}

const openAdd = () => { form.id = null; form.sectionName = ''; form.description = ''; form.status = 1; dialog.value = true }
const openEdit = (row) => {
  form.id = row.id
  form.sectionName = row.sectionName
  form.description = row.description
  form.status = row.status
  dialog.value = true
}

const save = async () => {
  if (form.id) await request.put(`/section/${form.id}`, form, { showDefaultMsg: false })
  else await request.post('/section/add', form, { showDefaultMsg: false })
  dialog.value = false
  load()
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确认删除分类「${row.sectionName}」吗？`, '提示', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await request.delete(`/section/${row.id}`, { successMsg: '删除成功' })
    load()
  } catch (e) {
    // 用户取消删除时不处理
  }
}

onMounted(load)
</script>

<style scoped>.section-management{padding:20px}</style>
