import GovernmentAgency from "../models/governmentAgency.model.js";

export const getGovernmentAgencies = async(req, res)=>{
    try {
        const response = await GovernmentAgency.findAll();
        res.status(200).json(response);
    } catch (error) {
        console.log(error.message);
    }
}

export const createGovernmentAgencies = async(req, res)=>{
    try {
        await GovernmentAgency.create(req.body);
        res.status(201).json({msg: "GovernmentAgency add"});
    } catch (error) {
        console.log(error.message);
    }
}

export const deleteGovernmentAgency = async(req, res)=>{
    try {
        await GovernmentAgency.destroy({
            where:{
                id: req.params.id
            }
        })
        res.status(200).json({msg: "GovernmentAgency berhasil di hapus"})
    } catch (error) {
        console.log(error.message);
    }
}

export const updateGovernmentAgency = async(req, res)=>{
    try {
        await GovernmentAgency.update(req.body,{
            where:{
                id: req.params.id
            }
        })
        res.status(200).json({msg: "GovernmentAgency berhasil di update"})
    } catch (error) {
        console.log(error.message);
    }
}